import { esc, toast, errorMessage } from '../ui.js';
import { uploadFile, MAX_FILE_BYTES } from '../attachments.js';
import { fieldInput, readFieldInput } from '../fields.js';
import { listForms, getForm, submitForm, formLink, questionType, questionField } from '../forms.js';

// Forms: the list of every form people can send (#/forms), and one form to
// fill in (#/forms/<id>). Open to everyone signed in, directors included.

export async function renderForms(el) {
  el.innerHTML = `
    <div class="page-header"><div>
      <h1>Forms</h1>
      <p class="muted">Ask another team for something. Each form sends your request to the right project, and the team picks it up from there.</p>
    </div></div>
    <div data-forms><p class="muted">Loading forms…</p></div>`;
  const box = el.querySelector('[data-forms]');
  let forms;
  try {
    forms = await listForms();
  } catch (error) {
    box.innerHTML = `<p class="form-error">${esc(errorMessage(error))}</p>`;
    return;
  }
  if (!forms.length) {
    box.innerHTML = '<div class="empty-state"><p>No forms yet. A project\'s editors can add one with <strong>Forms</strong> on the project page.</p></div>';
    return;
  }
  box.innerHTML = `<ul class="form-list">${forms.map(f => `
    <li class="card form-list-item">
      <div>
        <h2><a href="#/forms/${esc(f.id)}">${esc(f.name)}</a></h2>
        <p class="muted small">Goes to ${esc(f.project)}</p>
        ${f.intro ? `<p class="form-list-intro">${esc(f.intro.length > 220 ? `${f.intro.slice(0, 220)}…` : f.intro)}</p>` : ''}
      </div>
      <a class="btn btn-small" href="#/forms/${esc(f.id)}">Fill in</a>
    </li>`).join('')}</ul>`;
}

export async function renderForm(el, id) {
  el.innerHTML = '<p class="muted">Loading form…</p>';
  let form;
  try {
    form = await getForm(id);
  } catch (error) {
    el.innerHTML = `<p class="form-error">${esc(errorMessage(error))}</p>`;
    return;
  }
  if (!form) {
    el.innerHTML = `<a class="back-link" href="#/forms">← Forms</a>
      <div class="empty-state"><p>This form isn't available any more. Ask the team that shared it, or pick another one in Forms.</p></div>`;
    return;
  }
  const questions = (form.questions || []).filter(q => q.target !== 'field' || q.field);
  const label = q => `${esc(q.label || 'Question')}${q.required ? ' <span class="required-mark" aria-hidden="true">*</span>' : ''}`;
  // Text answers get a roomy box; everything else uses the field inputs
  // (dropdowns, tick boxes, dates, numbers)
  const plainText = q => q.target !== 'field' && questionType(q) === 'text';
  const isFile = q => questionType(q) === 'file';
  const input = q => {
    if (isFile(q)) return `<input type="file" id="fq-${esc(q.key)}" multiple><p class="muted small">Up to 25 MB each.</p>`;
    if (plainText(q)) return `<textarea id="fq-${esc(q.key)}" rows="3" maxlength="4000" ${q.required ? 'required' : ''}></textarea>`;
    return fieldInput(questionField(q), null);
  };

  el.innerHTML = `
    <a class="back-link" href="#/forms">← Forms</a>
    <section class="card form-page">
      <header class="form-page-head">
        <h1>${esc(form.name)}</h1>
        <p class="muted small">Goes to ${esc(form.project)}</p>
        ${form.intro ? `<p class="form-intro">${esc(form.intro)}</p>` : ''}
      </header>
      <form class="form-fill" novalidate data-form>
        <label class="field"><span>${esc(form.title_label)} <span class="required-mark" aria-hidden="true">*</span></span>
          <input name="title" required maxlength="300"></label>
        ${questions.map(q => `
          <div class="field" data-question="${esc(q.key)}">
            <label for="fq-${esc(q.key)}">${label(q)}</label>
            ${q.help ? `<p class="muted small field-help">${esc(q.help)}</p>` : ''}
            ${input(q)}
          </div>`).join('')}
        <p class="muted small"><span class="required-mark" aria-hidden="true">*</span> Required</p>
        <p class="form-error" data-error hidden></p>
        <div class="form-actions">
          <button class="btn btn-primary" type="submit">Send</button>
          <button class="btn btn-ghost" type="button" data-copy-link>Copy link to this form</button>
        </div>
      </form>
    </section>`;

  el.querySelector('[data-copy-link]').addEventListener('click', async () => {
    try {
      await navigator.clipboard.writeText(formLink(id));
      toast('Link copied');
    } catch { toast(formLink(id)); }
  });

  el.querySelector('[data-form]').addEventListener('submit', async event => {
    event.preventDefault();
    const formEl = event.currentTarget;
    const errorBox = formEl.querySelector('[data-error]');
    const button = formEl.querySelector('[type=submit]');
    errorBox.hidden = true;
    const title = formEl.elements.title.value.trim();
    const answers = {};
    const files = [];
    for (const q of questions) {
      const box = formEl.querySelector(`[data-question="${CSS.escape(q.key)}"]`);
      if (isFile(q)) {
        const picked = [...box.querySelector('input[type=file]').files];
        if (q.required && !picked.length) {
          errorBox.textContent = `Please attach a file for "${q.label}".`;
          errorBox.hidden = false;
          return;
        }
        const tooBig = picked.find(f => f.size > MAX_FILE_BYTES);
        if (tooBig) {
          errorBox.textContent = `“${tooBig.name}” is larger than 25 MB.`;
          errorBox.hidden = false;
          return;
        }
        files.push(...picked);
        continue;
      }
      let value = null;
      if (plainText(q)) {
        value = box.querySelector('textarea').value.trim() || null;
      } else {
        const target = box.querySelector('[data-field-id]');
        value = target ? readFieldInput(questionField(q), target) : null;
      }
      if (value != null && !(Array.isArray(value) && !value.length)) answers[q.key] = value;
    }
    button.disabled = true;
    let taskId;
    try {
      taskId = await submitForm(id, title, answers);
    } catch (error) {
      errorBox.textContent = errorMessage(error);
      errorBox.hidden = false;
      button.disabled = false;
      return;
    }
    // Files go onto the task just made (allowed for its sender for 30 minutes)
    const failed = [];
    for (const file of files) {
      button.textContent = `Attaching ${file.name}…`;
      try {
        await uploadFile(taskId, file);
      } catch {
        failed.push(file.name);
      }
    }
    el.querySelector('.form-page').innerHTML = `
      <div class="form-sent" role="status">
        <h1>Sent</h1>
        <p>Thanks. Your request “${esc(title)}” is now in ${esc(form.project)}, and the team will pick it up from there.</p>
        ${failed.length ? `<p class="form-error">These files couldn't be attached: ${esc(failed.join(', '))}. Send them to the team another way.</p>` : ''}
        <div class="form-actions">
          <button class="btn" type="button" data-again>Send another</button>
          <a class="btn btn-ghost" href="#/forms">All forms</a>
        </div>
      </div>`;
    el.querySelector('[data-again]').addEventListener('click', () => renderForm(el, id));
  });
}
