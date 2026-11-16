import { supabase } from '../supabase.js';
import { state } from '../state.js';
import { esc, options, toast, errorMessage, confirmDialog, formDialog } from '../ui.js';
import { BUSINESS_UNITS, loadDepartments } from '../departments.js';

// Capacity > Departments (Admin): the list of departments and the business
// unit each one belongs to. The five starting departments can be renamed or
// moved to another unit but not deleted; added ones can be deleted while
// nobody and no campaign belongs to them.

export async function renderDepartments(el) {
  el.innerHTML = `
    <div class="people-intro">
      <p class="muted">Every person and every campaign belongs to one department, and each department to one business unit.
        A campaign can also be <strong>for</strong> another department: Marketing campaigns are for Education, Planning Center, or both.</p>
      <button class="btn btn-primary" type="button" data-add>Add department</button>
    </div>
    <div data-list><p class="muted">Loading departments…</p></div>`;
  el.querySelector('[data-add]').addEventListener('click', () => openForm(el, null));
  await draw(el);
}

async function draw(el) {
  const list = el.querySelector('[data-list]');
  let campaigns;
  try {
    await loadDepartments();
    const { data, error } = await supabase.from('campaigns').select('department_id');
    if (error) throw error;
    campaigns = data;
  } catch (error) {
    list.innerHTML = `<p class="form-error">${esc(errorMessage(error))}</p>`;
    return;
  }
  const peopleIn = d => state.people.filter(p => p.department_id === d.id && p.active).length;
  const campaignsIn = d => campaigns.filter(c => c.department_id === d.id).length;
  const byUnit = Object.keys(BUSINESS_UNITS).flatMap(unit => state.departments.filter(d => d.business_unit === unit));

  list.innerHTML = `
    <div class="table-wrap">
      <table class="table">
        <thead><tr><th>Department</th><th>Business unit</th><th class="num">People</th><th class="num">Campaigns</th><th></th></tr></thead>
        <tbody>
          ${byUnit.map(d => `
            <tr data-id="${esc(d.id)}">
              <td><strong>${esc(d.name)}</strong></td>
              <td>${esc(BUSINESS_UNITS[d.business_unit])}</td>
              <td class="num">${peopleIn(d)}</td>
              <td class="num">${campaignsIn(d)}</td>
              <td class="nowrap row-actions">
                <button class="btn btn-small" type="button" data-edit>Edit</button>
                ${d.key || peopleIn(d) || campaignsIn(d) || state.people.some(p => p.department_id === d.id) ? ''
                  : '<button class="btn btn-small btn-ghost" type="button" data-delete>Delete</button>'}
              </td>
            </tr>`).join('')}
        </tbody>
      </table>
    </div>
    <p class="muted small table-note">A department can be deleted once nobody and no campaign belongs to it. The five starting departments are kept.</p>`;

  const find = button => state.departments.find(d => d.id === button.closest('tr').dataset.id);
  list.querySelectorAll('[data-edit]').forEach(button => button.addEventListener('click', () => openForm(el, find(button))));
  list.querySelectorAll('[data-delete]').forEach(button => button.addEventListener('click', () => remove(el, find(button))));
}

function openForm(el, dept) {
  formDialog({
    title: dept ? `Edit ${dept.name}` : 'Add department',
    submitLabel: dept ? 'Save' : 'Add department',
    body: `
      <label class="field"><span>Name</span>
        <input name="name" required maxlength="80" value="${esc(dept?.name || '')}"></label>
      <label class="field"><span>Business unit</span>
        <select name="business_unit">${options(BUSINESS_UNITS, dept?.business_unit || 'corporate')}</select></label>`,
    onSubmit: async form => {
      const values = { name: form.elements.name.value.trim(), business_unit: form.elements.business_unit.value };
      if (!values.name) return 'Give the department a name.';
      if (state.departments.some(d => d.id !== dept?.id && d.name.toLowerCase() === values.name.toLowerCase())) {
        return 'There is already a department with that name.';
      }
      const { error } = dept
        ? await supabase.from('departments').update(values).eq('id', dept.id)
        : await supabase.from('departments').insert(values);
      if (error) return errorMessage(error);
      toast(dept ? `${values.name} saved` : `${values.name} added`);
      await draw(el);
    },
  });
}

async function remove(el, dept) {
  const ok = await confirmDialog({
    title: `Delete ${dept.name}?`,
    message: 'Nobody and no campaign belongs to it, so nothing else changes. You can add it again later.',
    confirmLabel: 'Delete',
    danger: true,
  });
  if (!ok) return;
  const { error } = await supabase.from('departments').delete().eq('id', dept.id);
  if (error) {
    toast(errorMessage(error), 'error');
    return;
  }
  toast(`${dept.name} deleted`);
  await draw(el);
}
