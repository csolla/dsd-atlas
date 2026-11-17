-- 17_asana_templates.sql
-- The first batch of project templates, rebuilt from the Asana projects DSD
-- really copies (analysed 17 Nov 2026): DSD Clinics Coaching, Monthly
-- Payments & Invoice Control, DSD Clinics Onboarding, Clinic Offboarding,
-- Team Consultancy preparation and Job Scorecard. Needs 16_templates.sql.
-- Every task starts as To do. Tasks whose Asana assignee has an Atlas
-- account are assigned to them; the description says who usually does each
-- one. Asana image links can't be copied and say so. Real invoices and
-- client names were left out. Safe to run more than once.

begin;

-- DSD Clinics Coaching
insert into public.campaigns (id, name, description, department_id, for_department_id, status, start_date, end_date, owner_id, planned_hours, private, is_template)
values ('bba38802-10d5-5192-920e-9e4869db49bb', 'DSD Clinics Coaching', 'Coaching programme for a DSD Clinic: useful links, the introduction, the 8 CORE principles (each with its standard, content, reflection and actions) and the end of the coaching. Name the project “DSD Clinics Coaching - [Clinic or doctor] [Year]”.', public.department_id_for('delight'), public.department_id_for('delight'), 'planned', '2026-01-05', '2026-07-05', (select id from public.people where lower(email) like 'csolla@%' limit 1), 0, false, true)
on conflict (id) do nothing;
insert into public.sections (id, campaign_id, name, position) values ('8aa63435-d288-5522-9dcd-5f7e845dbace', 'bba38802-10d5-5192-920e-9e4869db49bb', 'USEFUL LINKS', 1000) on conflict (id) do nothing;
insert into public.sections (id, campaign_id, name, position) values ('9921c20c-b32b-5c07-a84b-c4d899f6a620', 'bba38802-10d5-5192-920e-9e4869db49bb', 'INTRODUCTION TO THE DSD COACHING', 2000) on conflict (id) do nothing;
insert into public.sections (id, campaign_id, name, position) values ('98bf2aa5-6a56-5a4e-b3c2-094e6302b20c', 'bba38802-10d5-5192-920e-9e4869db49bb', 'CORE', 3000) on conflict (id) do nothing;
insert into public.sections (id, campaign_id, name, position) values ('b0000e2d-72be-5189-be3d-a25a62c45967', 'bba38802-10d5-5192-920e-9e4869db49bb', 'CLINICAL', 4000) on conflict (id) do nothing;
insert into public.sections (id, campaign_id, name, position) values ('3f805058-df8d-5366-9039-a2be035c1662', 'bba38802-10d5-5192-920e-9e4869db49bb', 'END OF THE DSD COACHING', 5000) on conflict (id) do nothing;
insert into public.custom_fields (id, campaign_id, name, type, settings, position) values ('4f487d5f-ba09-5a1b-a8e9-9353d3ec6796', 'bba38802-10d5-5192-920e-9e4869db49bb', 'Coaching status', 'choice', '{"options": ["ON-TRACK", "OFF-TRACK", "AT RISK", "DONE"]}'::jsonb, 1000) on conflict (id) do nothing;
insert into public.custom_fields (id, campaign_id, name, type, settings, position) values ('2cdff08e-9ac3-544c-bd20-d6f3669bd526', 'bba38802-10d5-5192-920e-9e4869db49bb', 'Scorecard', 'number', '{}'::jsonb, 2000) on conflict (id) do nothing;
insert into public.tasks (id, campaign_id, parent_id, section_id, title, description, assignee_id, due_date, status, position) values ('ef2ca639-c75e-5f1b-ac4e-8542d8b82a00', 'bba38802-10d5-5192-920e-9e4869db49bb', null, '8aa63435-d288-5522-9dcd-5f7e845dbace', 'DSD Practice Monthly Report form', 'Before each DSD Coaching session, please fill out the DSD Practice Monthly Report, answering the questions based on the last full month prior to your coaching call. For example, if your call is on October 13th, you should report your KPIs for September.

These questions are designed to help you reflect on your progress and gain clarity about your clinic’s growth. They give both you and your Coach valuable insights into your clinic’s growth and workflow efficiency.

You’ll find questions like:
    How many DSD First and Second appointments you had this month
    How organized your photo and record collection was
    How well your presentations went
    How many patients accepted treatment and the average case value

Click here to access: https://form.asana.com/?k=gFh8NxXw2-SzH06zH3aZnQ&d=472634702533497', null, null, 'todo', 1000) on conflict (id) do nothing;
insert into public.tasks (id, campaign_id, parent_id, section_id, title, description, assignee_id, due_date, status, position) values ('580dfb23-9d02-519c-a92a-2b6a0c690c76', 'bba38802-10d5-5192-920e-9e4869db49bb', null, '8aa63435-d288-5522-9dcd-5f7e845dbace', 'CORE Scorecard link', 'The scorecard must be completed every three months, prior to a DSD Coaching Planning Session. Please wait for your coach’s guidance before completing it.

Click here to access the https://dsd-coaching.scoreapp.com', null, null, 'todo', 2000) on conflict (id) do nothing;
insert into public.tasks (id, campaign_id, parent_id, section_id, title, description, assignee_id, due_date, status, position) values ('e3cc7336-1583-53f2-a572-494e84afe649', 'bba38802-10d5-5192-920e-9e4869db49bb', null, '8aa63435-d288-5522-9dcd-5f7e845dbace', 'CLINICAL Scorecard link', 'The scorecard must be completed every three months, prior to a DSD Coaching Planning Session. Please wait for your coach’s guidance before completing it.

Click here to access the https://myscore.digitalsmiledesign.com/coachingclinical', null, null, 'todo', 3000) on conflict (id) do nothing;
insert into public.tasks (id, campaign_id, parent_id, section_id, title, description, assignee_id, due_date, status, position) values ('3f27f9ea-6ce8-5a6f-a1f3-3f07b76d5459', 'bba38802-10d5-5192-920e-9e4869db49bb', null, '9921c20c-b32b-5c07-a84b-c4d899f6a620', 'INTRO. Introduction to the DSD Coaching', 'Welcome to the DSD Coaching journey

Hello and welcome!
We’re so excited to have you here.

If you’re reading this, it means your clinic is about to begin a unique and powerful journey: a journey designed not just to teach you what to do, but to help you actually do it.

Because implementing change isn’t easy. It takes clarity, commitment, teamwork… and a bit of guidance. That’s exactly what the DSD Coaching is here to provide.

This isn’t a course.
It’s not a checklist.
It’s a personalized program created to help you transform how your clinic works: day by day, week by week.

You’ll be supported by your dedicated DSD Coach, who will walk beside your team every step of the way. Together, we’ll help you reflect on your current reality, identify what truly matters, and implement new systems that lead to better communication, more efficiency, and a more joyful way of working.

So before you hit play on the video below, take a moment to appreciate where you are: at the beginning of something exciting.

This is your chance to:
    Strengthen your team
    Improve your workflows
    Deliver a better experience to every patient
    And build a culture of constant growth and collaboration

The DSD Coaching is here to help you grow: not by adding more to your plate, but by helping you focus on what really matters.


Let’s get started!
We’re ready when you are!

⭐ Content: 
https://vimeo.com/1097489515/345105fad2?share=copy

[image in the Asana original, not copied]', null, null, 'todo', 4000) on conflict (id) do nothing;
insert into public.tasks (id, campaign_id, parent_id, section_id, title, description, assignee_id, due_date, status, position) values ('d7496952-ca48-5739-ba17-96664c979148', 'bba38802-10d5-5192-920e-9e4869db49bb', '3f27f9ea-6ce8-5a6f-a1f3-3f07b76d5459', null, '⭐ Read the task description above', null, null, null, 'todo', 1000) on conflict (id) do nothing;
insert into public.tasks (id, campaign_id, parent_id, section_id, title, description, assignee_id, due_date, status, position) values ('a9b92b86-8189-5de0-9078-83cad8879b98', 'bba38802-10d5-5192-920e-9e4869db49bb', '3f27f9ea-6ce8-5a6f-a1f3-3f07b76d5459', null, '⭐ Watch the [Video] What is the DSD Coaching?', null, null, null, 'todo', 2000) on conflict (id) do nothing;
insert into public.tasks (id, campaign_id, parent_id, section_id, title, description, assignee_id, due_date, status, position) values ('bcc059e1-8409-5957-8c86-2b93197835ee', 'bba38802-10d5-5192-920e-9e4869db49bb', null, '98bf2aa5-6a56-5a4e-b3c2-094e6302b20c', 'Principle 1: The DSD Coordinator and team + Storytelling', null, null, null, 'todo', 5000) on conflict (id) do nothing;
insert into public.tasks (id, campaign_id, parent_id, section_id, title, description, assignee_id, due_date, status, position) values ('12ada429-a3dd-5adc-b7d0-509c185d4955', 'bba38802-10d5-5192-920e-9e4869db49bb', 'bcc059e1-8409-5957-8c86-2b93197835ee', null, '🎯 Principle 1 standards', 'Principle 1: The DSD Coordinator and team + Storytelling


The Core of DSD Scorecard standards: 
"Our DSD Coordinator demonstrates knowledge, determination, and autonomy in their work and plays an essential role in nurturing patient relationships, ensuring the smooth flow of the DSD process, and facilitating case acceptance".

Checklist:
☐ Our DSD Coordinator is accountable, has the ability to lead, manage and coordinate other team members to do the DSD related tasks correctly and on time.
☐ The coordinator is consistently organized in their scheduling, task management, and follow-up, efficiently maintaining a structured system for tracking progress, tasks, and deadlines.
☐ The coordinator tailor their communication style to effectively communicate DSD concepts and principles to other team members and patients.
☐ Our DSD Coordinator is tech-driven', null, null, 'todo', 1000) on conflict (id) do nothing;
insert into public.tasks (id, campaign_id, parent_id, section_id, title, description, assignee_id, due_date, status, position) values ('92fb5aab-ae94-5e43-9da8-a9783a33b243', 'bba38802-10d5-5192-920e-9e4869db49bb', 'bcc059e1-8409-5957-8c86-2b93197835ee', null, 'Identify your DSD Coordinator', 'Principle 1: The DSD Coordinator and team + Storytelling

Identify your DSD Coordinator

Find and train the ideal DSD Coordinator for your practice.


This is your #1 priority, because this person will become the main driver of your DSD implementation and the key connector between your team, your patients, and the DSD vision.

The Core Phase of the DSD Coaching will focus heavily on training this person to become confident, proactive, and fully equipped to guide the team through every step of the transformation. They will become the right hand—and the heartbeat of your DSD journey as a DSD Clinic.

You may already have someone in your team with the ideal profile, or in some cases, this role can be shared between different team members depending on availability and strengths.

The DSD Coordinator’s responsibilities include two essential areas:
    Patient relationship and case acceptance: guiding patients through their journey with empathy, clarity, and confidence.
    Clinical workflow coordination: ensuring every DSD case is properly managed and executed, from digitalization to treatment planning and beyond.

⭐ Content:

[Document] The DSD Coordinator 
https://3439767.fs1.hubspotusercontent-na1.net/hubfs/3439767/DSD%20Coordinator-1.pdf https://3439767.fs1.hubspotusercontent-na1.net/hubfs/3439767/DSD%20Coordinator-1.pdf 
https://3439767.fs1.hubspotusercontent-na1.net/hubfs/3439767/DSD%20Coordinator%20GERMAN-1.pdf
https://3439767.fs1.hubspotusercontent-na1.net/hubfs/3439767/DSD%20Coordinator%20ESPA%C3%91OL-2.pdf
https://3439767.fs1.hubspotusercontent-na1.net/hubfs/3439767/DSD%20Coordinator%20ITALIANO.pdf

[Document] The DSD Coordinator: Job Position and Tips to Hire 
https://3439767.fs1.hubspotusercontent-na1.net/hubfs/3439767/DSD_Coordinator_description__job_position_and_tasks.pdf.pdf https://3439767.fs1.hubspotusercontent-na1.net/hubfs/3439767/DSD_Coordinator_description__job_position_and_tasks.pdf.pdf
https://3439767.fs1.hubspotusercontent-na1.net/hubfs/3439767/German%20-%20DSD%20Coordinator%20description%2c%20job%20position%20and%20tasks.pdf%20(1).pdf
https://3439767.fs1.hubspotusercontent-na1.net/hubfs/3439767/Espa%C3%B1ol%20-%20DSD%20Coordinator%20description%2c%20job%20position%20and%20tasks.pdf-1.pdf
https://3439767.fs1.hubspotusercontent-na1.net/hubfs/3439767/ITALIANO%20DSD%20Coordinator%20description%2c%20job%20position%20and%20tasks.pdf-1.pdf

https://vimeo.com/1097484241/cf26afb3eb?share=copy

[image in the Asana original, not copied]


🧠 Reflection:
    Do you currently have someone on your team who naturally takes ownership, connects well with patients, and understands the full DSD journey?
    Think about whether this person is already in place—or if you need to invest time in identifying and training them.
    How clear are the responsibilities of your DSD Coordinator role—and are they being supported and empowered by the rest of the team?
    Reflect on how defined the role is, and whether everyone understands its value and contributes to its success.
    What kind of patient experience are you currently delivering—and how could a well-trained DSD Coordinator elevate it?
    Consider the impact this role could have on storytelling, case acceptance, and the smooth execution of your clinical workflows.
    Who is or could be your DSD Coordinator? Name and position 

📋 Action:
Complete the subtasks below:

Checklist:
☐ ⭐ Read [Document] The DSD Coordinator
☐ ⭐ Read [Document] The DSD Coordinator: Job Position and Tips to Hire
☐ ⭐ Watch [Video] Who is the DSD Coordinator
☐ ⭐ Meet as a team and talk about all the DSD tasks
☐ ⭐ Discuss and assign these tasks based on each member''s skills and workload
☐ ⭐ Assess the need to hire a DSD Coordinator
☐ ⭐ Inform the DSD Coach who is the DSD Coordinator and make sure the person is in Asana', null, null, 'todo', 2000) on conflict (id) do nothing;
insert into public.tasks (id, campaign_id, parent_id, section_id, title, description, assignee_id, due_date, status, position) values ('62e55a65-084e-50e1-8545-b0f3b763dc62', 'bba38802-10d5-5192-920e-9e4869db49bb', 'bcc059e1-8409-5957-8c86-2b93197835ee', null, 'Identify your DSD Concierge', 'Principle 1: The DSD Coordinator and team + Storytelling

Identify your DSD Concierge

Find and empower the Ideal DSD Concierge for the practice.


This is a key step to ensure patients enjoy a smooth, personalized, and unforgettable experience throughout their DSD journey. The information below will help define and implement this role, adapting it to your clinic’s needs and making it an essential part of your patient experience strategy.

You may already have a team member with the right profile for this, or the responsibilities of a DSD Concierge may be shared between different people depending on availability and strengths.

The role of a DSD Concierge involves two main aspects:
1 – Patient journey logistics and flow coordination
2 – Creating a premium experience through personal attention and service mindset

⭐ Content:
[Document] The DSD Conciergehttps://3439767.fs1.hubspotusercontent-na1.net/hubfs/3439767/DSD%20Concierge.pdf
https://3439767.fs1.hubspotusercontent-na1.net/hubfs/3439767/DSD%20Concierge-2.pdf
https://3439767.fs1.hubspotusercontent-na1.net/hubfs/3439767/DSD%20Concierge%20German%20(1).pdf
https://3439767.fs1.hubspotusercontent-na1.net/hubfs/3439767/DSD%20Concierge%20ESPA%C3%91OL-2.pdf
https://3439767.fs1.hubspotusercontent-na1.net/hubfs/3439767/ITALIANO%20DSD%20Concierge.pdf
 
https://vimeo.com/1097483560/1ce4ff6cc1?share=copy

[image in the Asana original, not copied]


🧠 Reflection:
    Do you currently have someone on your team who naturally takes care of details, enjoys guiding patients, and creates a warm, premium experience?
    Think about whether this person could grow into the DSD Concierge role—or if those qualities are currently missing in your workflow.
    Is your current patient journey coordinated in a way that feels smooth and intentional—or are there moments of confusion, delay, or inconsistency?
    Reflect on where a DSD Concierge could make the experience more seamless, elegant, and emotionally connected.
    How would your patients describe their experience at your clinic today—and what would you like them to say instead?
    Use this gap to define what needs to change and how the DSD Concierge role could help deliver that transformation.
    Who is or could be your DSD Concierge? Name and position 

📋 Action:
Complete the subtasks below:

Checklist:
☐ ⭐ Read [Document] The DSD Concierge
☐ ⭐ Watch [Video] Who is the DSD Concierge
☐ Inform the DSD Coach who is the DSD Concierge and make sure the person is in Asana', null, null, 'todo', 3000) on conflict (id) do nothing;
insert into public.tasks (id, campaign_id, parent_id, section_id, title, description, assignee_id, due_date, status, position) values ('bf42de44-fe4c-580a-9272-3034f738b79a', 'bba38802-10d5-5192-920e-9e4869db49bb', 'bcc059e1-8409-5957-8c86-2b93197835ee', null, 'Understand the Roles, Challenges and Skillsets', 'Principle 1: The DSD Coordinator and team + Storytelling

Understand the Roles, Challenges and Skillsets.

Clarity and anticipation are key to successful teamwork.


Now that you’ve defined who is responsible for what in your clinic, it’s time to go one step deeper: understanding each role in the DSD workflow, the potential challenges that come with it, and the skills needed to perform it successfully.

When a clinic begins working with DSD, it''s common for team members to feel unsure about certain responsibilities, or for bottlenecks to appear when roles aren’t fully clear or well supported.

This task is designed to help you identify those challenges before they happen—or address them proactively if they already exist.

You’ll explore:
    The key roles involved in DSD implementation 
    The most common challenges each one might face
    The ideal mindset and skillsets required for each role to thrive
    And how to support one another with empathy, delegation, and team alignment

Understanding this will not only improve daily efficiency—it will also help you create a more supportive, balanced, and motivated team culture that drives better results and a better patient experience.

Let’s build clarity, prevent frustration, and empower each person to shine in their role.

⭐ Content:
https://vimeo.com/1097499326/43cf335002?share=copy

[image in the Asana original, not copied]


https://vimeo.com/1097480509/1419e8da04?share=copy

[image in the Asana original, not copied]


🧠 Reflection:
    Does every team member clearly understand their role within the DSD workflow—and how their contribution fits into the bigger picture?
    Think about whether there''s clarity not only in job titles, but in day-to-day responsibilities and interdependencies.
    What challenges have already surfaced (or could arise) related to team roles, communication, or overlapping tasks?
    Reflect on any tensions, delays, or confusion that could be resolved with better structure or support.
    What specific skills or habits would help each team member feel more confident and effective in their role?
    Consider how you can support development through training, shadowing, or simply better communication and feedback.

📋 Action:
Complete the subtasks below:

Checklist:
☐ ⭐ Watch [Video] Roles, challenges and skillsets for DSD
☐ ⭐ Watch [Video] Overcoming the most common challenges in DSD implementation
☐ ⭐ Write down 3 challenges you are currently experiencing implementing DSD', null, null, 'todo', 4000) on conflict (id) do nothing;
insert into public.tasks (id, campaign_id, parent_id, section_id, title, description, assignee_id, due_date, status, position) values ('bfb1c161-0a39-5995-a0b5-94e8049ac7d9', 'bba38802-10d5-5192-920e-9e4869db49bb', 'bcc059e1-8409-5957-8c86-2b93197835ee', null, 'DSD Storytelling: How to Explain ''What DSD is''', 'Principle 1: The DSD Coordinator and team + Storytelling

DSD Storytelling: How to explain what DSD is

Understanding what DSD is matters—but knowing how to explain it is just as important.


As a DSD Clinic team member, your ability to communicate what DSD means in a clear, confident, and human way will deeply influence how patients perceive your clinic and the value of your treatments.

The content below will help you:
    Understand the key concepts behind Digital Smile Design
    Adapt your language depending on who you’re talking to
    Create your own authentic version of the “What is DSD?” explanation
    Feel more confident when presenting DSD during conversations, calls, or appointments

Remember: you don’t need to memorize a script.
You just need to speak from the heart, with clarity and purpose.
This is your DSD Story—make it yours!

⭐ Content (Christian Coachman)
https://vimeo.com/812468561/96c5627482?share=copy

[image in the Asana original, not copied]


https://vimeo.com/812475544/077b3644dc?share=copy

[image in the Asana original, not copied]


https://vimeo.com/812475463/58e2e9e34b?share=copy

[image in the Asana original, not copied]



⭐ Content
https://vimeo.com/1097484192/2a85eb28ac?share=copy

[image in the Asana original, not copied]


[Document] DSD Storylines and Speeches
https://3439767.fs1.hubspotusercontent-na1.net/hubfs/3439767/Storylines%20DSD%20Coaching%20(1).pdf
https://3439767.fs1.hubspotusercontent-na1.net/hubfs/3439767/Storylines%20DSD%20Coaching%20GERMAN-2.pdf
https://3439767.fs1.hubspotusercontent-na1.net/hubfs/3439767/ESPA%C3%91OL%20Storylines%20DSD%20Coaching-1.pdf
https://3439767.fs1.hubspotusercontent-na1.net/hubfs/3439767/DSD%20Storylines%20ITALIANO.pdf

[Document] Conversations with patients. Not all smile designs are the same: why choosing an official DSD Clinic gives you something truly unique
https://docs.google.com/document/d/1vSxLVybHTIsJBeGXAm12prWW3hzhB1beH8DpX58VhH0/edit?usp=sharing
https://docs.google.com/document/d/1TBe9iPiDULhwTFg4PK_TI01gKiZGDg5DZT6l_tORf8g/edit?usp=sharing
https://docs.google.com/document/d/1Xu4RUiCowEvJq0Ilf1-jx_uQYHKpwYx3coWrA21mWKc/edit?usp=sharing
https://docs.google.com/document/d/1GyQjQNOVCiH8x4ZhnkhctbWScbN1kNqLoBLuqSoCH9g/edit?usp=sharing

⭐ Examples from DSD Clinics: How to explain what we do in a DSD Clinic to patients?
https://youtu.be/hgCVxiGvonQ?si=AaUeP7uNTrBhRqK0
https://vimeo.com/945893150/ded098f816?share=copy

🧠 Reflection:
    Do you feel prepared to explain what DSD is in your own words—clearly, naturally, and in a way that resonates with your patients? Think about whether you’ve practiced this enough and if the message feels authentic to you.
    When you talk about DSD, do your patients truly get it? Can they describe it to others with the same level of clarity and enthusiasm? Reflect on how your current explanations are landing and what might make them more effective.
    Has your team aligned on a shared way of explaining DSD, or is everyone improvising? Consider whether it would help to co-create a consistent (but flexible) message that everyone can personalize and feel confident using.

📋 Action:
Complete the subtasks below:

Checklist:
☐ ⭐ Watch the [Videos] from Christian Coachman (3 videos)
☐ ⭐ Watch the [Video] Your DSD Elevator Pitch
☐ ⭐ Read the [Document] ''DSD Storylines and Speeches''.
☐ ⭐ Read the [Document] ''Conversations with patients. Not all smile designs are the same: why choosing an official DSD Clinic gives you something truly unique''
☐ ⭐ Watch the [Video] examples from other DSD Clinics
☐ ⭐ Write down 3 Elevator Pitches (storylines/speeches) for the following different types of patients: — Suggestion for elevator pitch:
 Someone focused on esthetics and how they look your pitch
 Someone focused on function as they can''t chew well your pitch
 Someone that is not looking for a dental treatment but has indication (crowed teeth) your pitch
☐ ⭐ Use the document to create your own Storylines/Speeches on the 30 topics mentioned
☐ AI Prompt and examples — Prompt for AI:

Create personalized elevator pitches for Digital Smile Design (DSD), highlighting its unique benefits tailored to the following patient profiles:

 Appearance-Focused Patients:
 Emphasize how DSD enhances facial aesthetics through personalized smile design using digital libraries. Mention the use of natural digital tooth shapes, textures, and the “copy-paste” concept for creating authentic and harmonious smiles that fit each patient’s unique features.
 Function-Focused Patients:
 Highlight how DSD restores chewing and speaking function through 3D software planning. Explain how specialists collaborate virtually, testing multiple treatment possibilities to create the most effective and lasting solution while ensuring facial balance and restored function.
 Unaware but Needing Treatment:
 Use a warm, empathetic tone to acknowledge that dental treatment may not be a priority for some. Stress how DSD simplifies the process by using advanced tools to evaluate the patient’s current dental situation. Focus on making treatment options easy to understand, empowering patients to make well-informed decisions at their own pace and without pressure.
 Technology Enthusiasts:
 Highlight DSD’s tech-driven approach, emphasizing its use of 3D software similar to AutoCAD for architects. Describe how every treatment is digitally designed, ensuring unparalleled precision, predictability, and the ability to visualize final results before starting the treatment.
 Dental Anxiety Patients:
 Adopt a compassionate tone and emphasize DSD’s patient-centered approach. Mention how digital previews of the final result provide clarity and reduce uncertainty. Highlight how the treatment process is transparent, supportive, and free of surprises, offering comfort and building trust through every step.
 First-Time Smile Investors:
 Use an empathetic and reassuring tone to address concerns about investing in a smile. Emphasize DSD’s fully personalized treatment plans, designed for long-term health, function, and aesthetics. Mention how digital previews, clear communication, and step-by-step guidance help patients see the value of their investment, ensuring a life-changing transformation tailored specifically for them.

Use these guidelines to create compelling, patient-specific elevator pitches that highlight DSD’s comprehensive benefits.



Example answers:

1. Appearance-Focused Patients
“Imagine having a smile that perfectly complements your unique facial features. With Digital Smile Design (DSD), we use cutting-edge digital libraries to select natural tooth shapes, textures, and even clone real smiles through our ‘copy-paste’ concept. This means your new smile will look authentic, personalized, and naturally beautiful, designed specifically for you with unmatched precision.”

2. Function-Focused Patients
“Chewing and speaking comfortably shouldn’t be a struggle. With DSD, we use advanced 3D software to plan every detail of your treatment focusing on longevity. We collaborate with specialists across disciplines, testing multiple treatment possibilities virtually to create the most effective and long-lasting solution. This ensures not only restored function but also improved facial harmony and confidence.”

3. Unaware but Needing Treatment
“We understand that seeking dental care might not be on your radar, and it can feel overwhelming. That’s why at DSD, we make the process simple and transparent. Using the latest digital tools, we evaluate your current dental situation and explain everything clearly, showing you personalized treatment possibilities. Our goal is to inform you so you can make confident, well-informed decisions about your oral health: at your own pace and with complete understanding.”

4. Technology Enthusiasts
“If you love advanced technology, DSD will exceed your expectations. We use 3D software similar to what architects use in AutoCAD to digitally design every aspect of your smile. This tech-driven approach ensures unparalleled precision, predictability, and the ability to visualize your final result before we even begin treatment.”

5. Dental Anxiety Patients
“We understand that visiting the dentist can be stressful, but with DSD, we turn fear into confidence. You’ll see a digital preview of your future smile before any treatment starts, giving you clarity and peace of mind. Our step-by-step process keeps you informed, while our caring team supports you with empathy and patience. No surprises: just a safe, caring and comfortable experience designed entirely around you.”

6. First-Time Smile Investors
“Investing in your smile can feel like a big step, and we’re here to make it worth your while. With DSD, you’ll receive a fully personalized treatment plan designed for long-term health, function, and beauty. We’ll guide you through every step, showing you digital previews and explaining all options clearly. It’s more than a treatment: it’s a life-changing transformation crafted just for you, with results that boost your health and confidence for years to come.”', null, null, 'todo', 5000) on conflict (id) do nothing;
insert into public.tasks (id, campaign_id, parent_id, section_id, title, description, assignee_id, due_date, status, position) values ('43ddbeda-414b-50b3-b6bd-3085aaf7290e', 'bba38802-10d5-5192-920e-9e4869db49bb', 'bcc059e1-8409-5957-8c86-2b93197835ee', null, 'Common Communication Mistakes in Patient Conversations', 'Common Communication Mistakes in Patient Conversations

Clear, empathetic, and structured communication is one of the most powerful tools a DSD Clinic can develop.
Even the most advanced workflow or the most beautiful design can lose impact if the conversation surrounding it creates confusion, pressure, or emotional disconnect.

This task focuses on the most frequent communication mistakes that appear in emotional, clinical, and financial conversations with patients—from subtle tone misalignments to major ethical risks.

Understanding these mistakes (and learning how to avoid them) is essential for building trust, presenting value, guiding patients, and improving case acceptance in a healthy, ethical way.

The content below will help you:
    Recognize communication patterns that create mistrust, confusion, or pressure.
    Understand how tone, boundaries, and emotional awareness shape the patient’s experience.
    Identify blind spots in your personal communication style.
    Learn the recommended alternatives for each error category and apply them with confidence.
    Strengthen unity and consistency across the entire DSD Clinic team.

Remember:
Great communication is not about being perfect.
It’s about being aware, intentional, and aligned with the experience you want your patients to have.



⭐ Content:

[Document] Common Communication Mistakes in Patient Conversations
https://docs.google.com/document/d/14lO0kEg3Z5X4oe9bonT7_0lU9kRRbo7fBNWBZIkmaUY/edit?usp=sharing
https://docs.google.com/document/d/1UhqZUFhkZMu_TNX5-qj4wM87w0kYMpYf_yqBYDPaCR0/edit?usp=sharing
https://docs.google.com/document/d/1kH5er56CqDotxLs7N-F_uAAsP5rvgrmMJ7TeYBZBGf4/edit?usp=sharing
https://docs.google.com/document/d/1tnfoRUJRUTWOSeQ_uHNvODY8lDkGtxfTTcpSUtKQuHo/edit?usp=sharing



🧠 Reflection:
Use these questions to deepen your awareness and transform this list from “information” into “skill.”

1. Personal Awareness
    When you read through the list, which categories felt most familiar to you?
    Are there moments in past patient conversations where you recognize these patterns—defensiveness, over-explaining, rushing, or lack of structure?

2. Emotional Intelligence
    How comfortable do you feel managing emotions—your own and the patient’s—during a difficult conversation?
    Which emotional triggers (hesitation, comparisons, financial concerns, criticism) tend to affect your tone or rhythm the most?

3. Team Consistency
    Does your team communicate with patients using consistent language, tone, and terminology?
    Or do different team members explain things in different ways, creating mixed messages?
    What would help you all align better?

4. Patient Experience Impact
    How might these communication mistakes influence case acceptance, patient trust, and the emotional perception of your clinic?
    Imagine your last three important patient conversations—what signals might the patient have received without you realizing it?

5. Growth Mindset
    Which recommended alternatives (“what to do instead”) feel natural to you, and which will require deliberate practice?
    What small change could you start applying immediately in your next patient interaction?



📋 Action:
Complete the subtasks below:

Checklist:
☐ ⭐ Read the [Document] ''Common Communication Mistakes in Patient Conversations''', null, null, 'todo', 6000) on conflict (id) do nothing;
insert into public.tasks (id, campaign_id, parent_id, section_id, title, description, assignee_id, due_date, status, position) values ('ac202a9e-646e-5925-a749-35dfa2a83ead', 'bba38802-10d5-5192-920e-9e4869db49bb', 'bcc059e1-8409-5957-8c86-2b93197835ee', null, 'Manage the Team', 'Principle 1: The DSD Coordinator and team + Storytelling

Manage your team with clarity and connection.


Once everyone understands their role and responsibilities, the next step is to ensure things stay on track—and that requires consistent, open communication.

People need to feel heard, informed, and involved. In fact, effective communication is one of the key ingredients for successful DSD implementation.

Keeping communication flowing isn’t just about logistics—it’s about building trust, motivation, and a shared sense of purpose.
That’s how great teams grow.


⭐ Content:
[Document] Managing the Team: Tools, Communication, Systems and Platforms

https://docs.google.com/document/d/1taEf6XchwfMPBVYTa_bZ-DGA-BkKUJQevdxbFE37J34/edit?usp=sharing
https://docs.google.com/document/d/12hWHert2z2Nhji8f4zy6TrSToII6xCPj13Hwcz7pLHk/edit?usp=sharing
https://docs.google.com/document/d/12CZcjMm3iYCvultkxRAK9l1r7gkOb2pvsG9rASh1AnM/edit?usp=sharing
https://docs.google.com/document/d/1rk4E9V1OTPYXop6-DxW0KdiaMJt4-CBNoAm-K2lP6VI/edit?usp=sharing


[image in the Asana original, not copied]



🧠 Reflection:
    How consistent and open is your team communication right now—and do all team members feel heard and included?
    Think about whether your current system encourages regular check-ins, honest dialogue, and shared understanding.
    When things go off track, is it usually due to lack of clarity, unclear roles, or communication gaps?
    Reflect on how you could prevent misunderstandings or delays by improving the way you align and inform your team.
    What regular rituals or habits do you have in place to keep your team connected and focused on your shared goals?
    Consider whether you need to create or strengthen team meetings, daily huddles, or open spaces for feedback and collaboration.

📋 Action:
Complete the subtasks below:

Checklist:
☐ ⭐ Read the [Document] Managing the Team: Tools, Communication, Systems and Platforms
☐ ⭐ Set up a Weekly or Bi-Weekly Meeting for the team
☐ ⭐ Create an Organizational Chart that outlines your team, their roles, and key responsibilities', null, null, 'todo', 7000) on conflict (id) do nothing;
insert into public.tasks (id, campaign_id, parent_id, section_id, title, description, assignee_id, due_date, status, position) values ('23f2edc2-6f70-554f-a037-f85b2b57c840', 'bba38802-10d5-5192-920e-9e4869db49bb', 'bcc059e1-8409-5957-8c86-2b93197835ee', null, 'Clinic Culture & Core Values', 'Principle 1: The DSD Coordinator and team + Storytelling

Clinic Culture & Core Values

Creating and maintaining a strong, positive clinic culture is essential for the well-being of the team and the quality of patient care. 


When time passes and stressful situations arise, it’s easy to let caring communication and the clinic''s culture take a backseat. That’s why we’ve created this section: to revive who we truly are, create a pleasant and close-knit environment where everyone feels comfortable at work, and ensure our patients perceive it as well. Returning to the values of respect, gratitude, and recognition must be a fundamental pillar of the clinic.

We have created a team survey that will help your clinic assess whether its culture and core values are well established, require refinement, or need urgent restoration. The responses will provide valuable insight into areas that may need attention while ensuring that the feedback remains constructive and respectful 

[GET a copy of the survey HERE] ⬇️ ⬇️ ⬇️
https://docs.google.com/forms/d/1QYuUoqaB_kNkXzntUiyALu1s2qud3ZOeyp-JT7Fmq4c/copy
https://docs.google.com/forms/d/1_63oSXwbxqD3MWcIE6fzdSLegvKTGjPi4fRRLdr8LQI/copy
https://docs.google.com/forms/d/1cwTLvVeXFq0K6RO2desHLX-ViUFdEHYndtfdNLGwttM/copy
https://docs.google.com/forms/d/13PLHrGfCxv6puAUGSFkR4zEV1LFW7bRgHlrwHQs6EwI/copy

⭐ Content:
➡️ ➡️ ➡️ Please watch the https://vimeo.com/1098467744/27734dd910?share=copy ''Step by Step'' Instructions on how to use this form before using it ⬅️ ⬅️ ⬅️

Written version of the
''Step by Step'' Instructions HERE [Document]⬇️ ⬇️ ⬇️
https://docs.google.com/document/d/1qYcNblsicBfw6ndpsjNwkzkdDUdqRTTx1-Kt5LqLNYI/edit?usp=sharing
https://docs.google.com/document/d/1iKlSEuII9w-td5xnvmtfYU2OLSrCtG98dvTDnSvmo0Q/edit?usp=sharing
https://docs.google.com/document/d/1BRoxUcB3ZpcaHi1hDISwYcX8nGxUrB37fJIkCeV-vDs/edit?usp=sharing
https://docs.google.com/document/d/1Tu7zHJyB1cZz8vNIaYzmHgcYezLxog60xYqg438iVJk/edit?usp=sharing

How does it work? 
    Each team member completes the survey anonymously. 
    Once all responses are collected, managers should analyze the results and determine the key takeaways. 
    From there, you can hold a group session to review the findings together, celebrate what’s working well, talk about how to maintain it over time, and brainstorm ways to improve areas that need attention. 
    This creates an open and constructive space for alignment and team growth!


🔔 🔔 🔔 IMPORTANT NOTE 🔔 🔔 🔔
When you open the Asana link, you will be prompted to create a copy. Please make sure to open the link only once and generate a single copy for the entire team. Once the copy is created, share the specific link explained in the video (not the original Asana link) with your team members so they can collaborate within the same document.

⚠️ WHAT NOT TO DO: If each team member clicks on the original Asana link and creates their own separate copy, the responses will be spread out and disorganized, making it impossible to see all the answers in one place: which defeats the entire purpose of the workshop!

If you have questions, don''t hesitate to ask your Coach 🙂



🔔 🔔 🔔  Every clinic deserves to be a place where people feel respected, valued, and motivated. But with daily pressures, it''s easy to lose sight of how we treat each other. Having a shared agreement helps us pause, realign, and protect the positive culture we want to build. This document below is an example of how a team can define its values, set expectations, and create a safe, supportive environment where everyone thrives: professionally and personally.

[Document] Healthy Work Environment Agreement
https://docs.google.com/document/d/10swytkYpXsrNURyD7GE9PtpBHCJfs5oTbiTQ5-sfsdQ/edit?usp=sharing
https://docs.google.com/document/d/1lnUKmkiFqJ-gFG_KOfihKIWYXxRFOyVZjgpP64JsaaE/edit?usp=sharing
https://docs.google.com/document/d/1J77pelaya1Rou1mPmuuh-ioEm_sag8_3BzsqJqWREDQ/edit?usp=sharing
https://docs.google.com/document/d/1ldytXVjxP1oELhUngc1jtTjunmy-f4TOOhoS2WtJlxk/edit?usp=sharing


🧠 Reflection:
    How would your team describe your clinic culture today—and is that the culture you want to be known for?
    Think about whether daily behaviors, tone, and environment truly reflect the values your clinic stands for.
    When was the last time you talked openly as a team about respect, gratitude, recognition, and emotional well-being at work?
    Reflect on how often these important but intangible elements are actively nurtured—or unintentionally neglected.
    How do you make sure your clinic culture is not just written in documents, but felt by your team and your patients every day?
    Consider whether your values are visible in how you lead, collaborate, and celebrate—especially under pressure.

📋 Action:
Complete the subtasks below:

Checklist:
☐ ⭐ Read the task description on ‘Clinic Culture & Core Values’.
☐ ⭐ Watch the [Video]: Instructions on how to use the ''Clinic Culture & Core Assessment'' form and/or Read the ''Step by Step'' Instructions [Document]
☐ ⭐ Read the [Document] Healthy Work Environment Agreement
☐ ⭐ Ideally, all members of the clinic team should respond anonymously and honestly to the survey
☐ ⭐ Managers should evaluate the responses in a specific session
☐ ⭐ Hold a group session to review the findings together, celebrate what’s working well, talk about how to maintain it over time, and brainstorm ways to improve areas that need attention.
☐ ⭐ Hold frequent meetings to review this content and stay aligned.', null, null, 'todo', 8000) on conflict (id) do nothing;
insert into public.tasks (id, campaign_id, parent_id, section_id, title, description, assignee_id, due_date, status, position) values ('8a4810cb-b90c-56be-bfb7-751b1e8ff411', 'bba38802-10d5-5192-920e-9e4869db49bb', null, '98bf2aa5-6a56-5a4e-b3c2-094e6302b20c', 'Principle 2: The DSD Room, Ambiance and Patient Experience', null, null, null, 'todo', 6000) on conflict (id) do nothing;
insert into public.tasks (id, campaign_id, parent_id, section_id, title, description, assignee_id, due_date, status, position) values ('9f8c1fbb-2c8b-5be3-85dd-62ae366fd0d3', 'bba38802-10d5-5192-920e-9e4869db49bb', '8a4810cb-b90c-56be-bfb7-751b1e8ff411', null, '🎯 Principle 2 standards', 'Principle 2: The DSD Room, Ambiance and Patient Experience

The Core of DSD Scorecard standards: 
"The ambiance of our clinic reflects high standards. It is a pleasant, soothing, and beautiful atmosphere, distinct from traditional dental clinics."

Checklist:
☐ The overall environment of our office, focused attention to detail, coupled with a designated DSD Room, surpasses patient expectations. With an aesthetic touch in every room, we chose curated elements such as special decor, scents, music, and indirect lighting.
☐ We have assessed the clinic''s environment and patient experience, reviewed consultancy recommendations, defined our improvement priorities, and initiated an execution plan, within the allocated budget.
☐ Our DSD Room is equipped with the necessary technology (iOS, computer, TV/screen, camera/phone, LED/flashes, background, etc.) for first and second appointments, with a designated space for photos and videos as well as comfortable seating for case presentations with a large TV.
☐ The clinic’s pleasant ambiance contributes to enhanced patient enjoyment during visits, increases perceived value and trust in the team, and fosters better understanding and acceptance of proposed treatments.', null, null, 'todo', 1000) on conflict (id) do nothing;
insert into public.tasks (id, campaign_id, parent_id, section_id, title, description, assignee_id, due_date, status, position) values ('5d654eea-9dd4-5a64-8fe0-27a62cadaec1', 'bba38802-10d5-5192-920e-9e4869db49bb', '8a4810cb-b90c-56be-bfb7-751b1e8ff411', null, 'The DSD Room', 'Principle 2: The DSD Room, Ambiance and Patient Experience


The DSD Room is not just a space: it’s a strategic tool to elevate the patient experience and reinforce your clinic’s identity.
It’s where emotional connections happen. 
Where the DSD Story comes to life. 
Where patients begin to see themselves differently and dream of what’s possible.

This space should feel intentional, inspiring, and aligned with your brand. It’s about creating the right ambiance to support meaningful conversations, showcase visual tools, and present treatment plans in a way that builds trust and excitement.

There’s no one-size-fits-all layout. Each DSD Room is unique and should reflect your clinic’s size, structure, and resources. But there are key elements and best practices that help you get the most out of it.

To discover how to shape your own DSD Room, whether it''s a fully dedicated space or a multi-use area, start by watching the videos below.

Let’s design a space that speaks for you… before you say a word.

⭐ Content:

https://vimeo.com/566864720/00a13a4a30?share=copy

[image in the Asana original, not copied]


https://vimeo.com/816958350/6efeb03e48?share=copy

[image in the Asana original, not copied]


https://vimeo.com/817231890/8b5fd2787d?share=copy

[image in the Asana original, not copied]


[Document] About the DSD Room
https://3439767.fs1.hubspotusercontent-na1.net/hubfs/3439767/DSD%20Room%20by%20Luken%20FINAL.pdf
https://3439767.fs1.hubspotusercontent-na1.net/hubfs/3439767/Cream%20Minimalist%20Photography%20Presentation.pdf
https://3439767.fs1.hubspotusercontent-na1.net/hubfs/3439767/DSD%20Room%20by%20Luken%20FINAL.pdf.pdf
https://3439767.fs1.hubspotusercontent-na1.net/hubfs/3439767/ITALIANO%20DSD%20Room%20by%20Luken%20FINAL.pdf.pdf

[Document] DSLR Photography Studio for DSD Clinics: A Practical Guide
https://docs.google.com/document/d/1F-Mb410kDr8UUIUSAtpehBpoSRrXakzVwYW7A36rxfA/edit?usp=sharing
https://docs.google.com/document/d/1YPl8-IG63_-mAg6yza0KG-s6YyPvSrcjOacn97242Ok/edit?usp=sharing
https://docs.google.com/document/d/1NI_UIrNmjOimIQ0_wy7OzutSC88oH_3iWcxIU_e0coI/edit?usp=sharing
https://docs.google.com/document/d/1QqZogpxslVaqzGskrwnAbHfplgbfgGf0yifZayEGTEo/edit?usp=sharing

🧠 Reflection:
    What does your current DSD Room/space communicate to your patients—before anyone even starts speaking?
    Reflect on whether the ambiance, layout, and details of your space are reinforcing the emotional and visual experience you want to create.
    Is your DSD Room (or presentation area) designed to support trust, storytelling, and connection—or is it just another treatment room?
    Think about how you could adapt or improve the space to make it more intentional, memorable, and aligned with your brand.
    What small changes could you make—today—that would elevate the way patients feel in this space?
    Consider lighting, seating, visuals, sounds, smells, and the overall flow. Sometimes, subtle shifts have a big emotional impact.

📋 Action:
Complete the subtasks below:

Checklist:
☐ ⭐ Watch the [Video] ''The DSD Room by Dr. Christian Coachman''
☐ ⭐ Watch the [Video] ''Your DSD Room and Patient Digitalization''
☐ ⭐ Watch the [Video] ''How to set up your Photography Studio''
☐ ⭐ Read the [Document] ''About the DSD Room''
☐ ⭐ Read the [Document] ''DSLR Photography Studio for DSD Clinics: A Practical Guide''
☐ Set up your own DSD Room following the standards recommended
☐ Take photos of your current DSD Room/space and share them here with your DSD Coach
☐ Record a video about your DSD Room explaining every detail to share it here with your DSD Coach', null, null, 'todo', 2000) on conflict (id) do nothing;
insert into public.tasks (id, campaign_id, parent_id, section_id, title, description, assignee_id, due_date, status, position) values ('20456750-a3fa-50a3-a0fd-ba8136a96dc4', 'bba38802-10d5-5192-920e-9e4869db49bb', '8a4810cb-b90c-56be-bfb7-751b1e8ff411', null, 'The Patient Experience and Clinic Decor', 'Principle 2: The DSD Room, Ambiance and Patient Experience

Rethink the Patient Experience at Your Practice


"Service is black and white—hospitality is color."

In today’s world, offering great dentistry is no longer enough. Patients seek more than treatment: they seek connection, clarity, and confidence. That’s why, at DSD, we embrace a philosophy of Comprehensive Digital Care, where the patient experience becomes the heart of everything we do.

This experience begins long before treatment starts, and it continues well after it ends. It’s shaped by every detail: how your team communicates, how your spaces feel, how patients are guided, educated, and inspired along the way.

Clinics all over the world are embracing this mindset and going the extra mile: not only to deliver excellent dentistry, but to create moments that patients will remember, talk about, and value deeply.

There is a huge opportunity to grow your practice by elevating how patients feel in every interaction. This is not about adding more work: it’s about working with more purpose and intention!

Now is the time to rethink your current experience.

⭐ Content:
https://vimeo.com/817231540/bcbba4e343?share=copy

[image in the Asana original, not copied]


[Document] Clinic Decor: Creating a Beautiful, Intentional Space Without Full Renovation
https://docs.google.com/document/d/1v39QZQXYFHP4Cy8alqN_1mLaX4IdSKxiE7f0-PXv0K0/edit?usp=sharing
https://docs.google.com/document/d/1aCNJJJ228fhvDQrrKFY6MlmZiQVXVdqDHB0a5DYXLeE/edit?usp=sharing
https://docs.google.com/document/d/1btjfiWeZ3GsMCPNU47VcFln4C3kotDbsRb-ju9E2OnA/edit?usp=sharing
https://docs.google.com/document/d/1AACvLhwocGSVTDzwFJJ0WnRgFHtt2_KWxhTc3ptXgkY/edit?usp=sharing

[Document] Strategic Guide: Clinic Renovation & Patient Experience
https://docs.google.com/document/d/128SYuszSzOYEEMIML52fQRboTIikbPGBc6q28EOAhEw/edit?usp=sharing
https://docs.google.com/document/d/1nmF4MkNfh_kcArmPN4zUOurHpSL79WEdUcw55T50IdQ/edit?usp=sharing
https://docs.google.com/document/d/1MzZbShHYpqLYX4XRNZp_ksDE73auST7XibNOA4S7Mgs/edit?usp=sharing
https://docs.google.com/document/d/1nck5l75pAH169LfMDfiLsDGwUAALvHBf1dUQ7uzMPds/edit?usp=sharing

🔄 Extra Content/Suggestions (not mandatory!):
https://vimeo.com/999542467/4194e06659?share=copy
https://www.amazon.com/Unreasonable-Hospitality-Remarkable-Giving-People/dp/0593418573/ref=tmm_hrd_swatch_0?_encoding=UTF8&dib_tag=se&dib=eyJ2IjoiMSJ9.LWq_lwhxAYDoe9jVpbqe8J0F4f4uhpKD9cWRq0fKtja0NHIoFbK1a5LE_BCckWKHmZmugqaNfdhHatmJR0Bj_FheJJxNkg0MhiFEeHPN3xq1kDvOahb3_77ybOVnGTH3WaK9oifwUUAjrF5DU0p1w-s4ZngHHvR70JhinxNxyYUhVaW31d3hcj590sKUe4JmkVpp8xobGXvVx5nwfzdmjFlwGIXFObu6TIqd117YlGU.Ht_A61si9lGZhnPqSeQMaG3wPtPEYE2PvnMs4hoxz_Q&qid=1714610469&sr=8-1
https://vimeo.com/999542309/11af6d7472?share=copy
https://vimeo.com/999542329/cdfdfd6bf2?share=copy
https://digitalsmiledesign.notion.site/Inspirational-Cards-77c1b0aaee3644c0bd8852294376f0e1from the DSD Marketing Co-Grow.

🧠 Reflection:
    If you walked into your clinic today as a new patient, what would your first impression be—from the first phone call to the first appointment?
    Reflect honestly on what your current experience communicates: Is it warm? Clear? Memorable? Or purely clinical?
    Are you offering a service… or creating a meaningful experience?
    Think about how your team, environment, and communication can shift from delivering procedures to delivering emotions, trust, and connection.
    What small, intentional changes could you make that would turn routine moments into unforgettable ones?
    Consider how you can transform everyday interactions into something patients will remember and share—not by doing more, but by doing it with purpose.

📋 Action:
Complete the subtasks below:

Checklist:
☐ ⭐ Watch the [Video] Deep Dive into a DSD Clinic Patient Experience
☐ ⭐ Read the [Document] ''Clinic Decor: Creating a Beautiful, Intentional Space Without Full Renovation''
☐ ⭐ Read the [Document] ''Strategic Guide: Clinic Renovation & Patient Experience''
☐ ⭐ What aspects of the current patient experience would you like to change or improve?
Think about moments that feel rushed, unclear, or uninspiring—from first contact to follow-up. Please write your answers in the comments section of this task. — ⭐ What things would you like to change about the experience at your clinic?

WRITE IN THE COMMENTS AND TAG YOUR DSD COACH
☐ ⭐ What new ideas or inspirations would you love to implement to elevate the patient experience?
Consider changes in communication, ambiance, flow, or emotional impact! Please write your answers in the comments section of this task. — ⭐ What ideas would you like to apply at your clinic to improve patient experience?

WRITE IN THE COMMENTS AND TAG YOUR DSD COACH
☐ [Watch] and/or [Read] the Extra Content/Suggestions (not mandatory!)', null, null, 'todo', 3000) on conflict (id) do nothing;
insert into public.tasks (id, campaign_id, parent_id, section_id, title, description, assignee_id, due_date, status, position) values ('ec76bec1-7c68-5e4a-afd2-e4c21b8b5fdd', 'bba38802-10d5-5192-920e-9e4869db49bb', null, '98bf2aa5-6a56-5a4e-b3c2-094e6302b20c', 'Principle 3: The DSD 1st Appointment', null, null, null, 'todo', 7000) on conflict (id) do nothing;
insert into public.tasks (id, campaign_id, parent_id, section_id, title, description, assignee_id, due_date, status, position) values ('9173f835-ffe1-523e-bef4-c16e71627e4b', 'bba38802-10d5-5192-920e-9e4869db49bb', 'ec76bec1-7c68-5e4a-afd2-e4c21b8b5fdd', null, '🎯 Principle 3 standards', 'Principle 3: The 1st Appointment

The Core of DSD Scorecard standards: 
"Our clinic revolutionizes the patient''s first appointment experience by focusing on personalized attention, leveraging the latest technology for patient digitalization, and adopting a holistic approach to screening and diagnosis."

Checklist:
☐ We have invested in the latest technology (such as intraoral scanning, digital photography, and CBCT), and we routinely assess and refresh the equipment as needed.
☐ Our front desk team and DSD Coordinator know how to explain and talk about DSD communicating confidently with patients. Training is provided and encouraged.
☐ During the 60-minute first appointment, our team uses the technology for patient data intake (photos video, intraoral scan, etc), ensuring records are accurately taken, stored, and shared using cloud dentistry concepts.
☐ Our patients perceive the quality and differentiation of our first appointment by the processes we follow, the innovative way we collect data, the attention to detail, the comprehensive diagnosis of their dental needs, and the customer experience plan we provide.', null, null, 'todo', 1000) on conflict (id) do nothing;
insert into public.tasks (id, campaign_id, parent_id, section_id, title, description, assignee_id, due_date, status, position) values ('453c3278-b5b3-5390-b32e-4a570b98406e', 'bba38802-10d5-5192-920e-9e4869db49bb', 'ec76bec1-7c68-5e4a-afd2-e4c21b8b5fdd', null, 'Assign the DRIs (Direct Responsible Individual) for every 1st appointment task', 'Principle 3: The 1st Appointment

Clear roles create confident teams, especially when implementing something new!


When starting with DSD, it’s very important that everyone knows what’s expected from them. This avoids confusion, builds trust, and helps the entire workflow run more smoothly.

In some small clinics, one person may handle many of the tasks, but in most cases, responsibilities are shared across the team. 

What matters is that each step is covered, proper training is in place, and everyone understands their role.

Let’s begin by looking at one of the most important moments: the DSD First Appointment.
Take a moment as a team to write down who is responsible for each step of this visit.
This will help you delegate clearly, identify any missing pieces, and ensure consistency in the patient experience.

    Who performs the initial chat with the patient? Write name and position 
    First contact with the patients, interview, chief complaint, talk about expectations, explain what the 1st Appointment is going to be like: make the patient ready. Write name and position 
    Who takes the initial photos and videos (DSD Protocol 5 pictures + video)?  Write name and position 
    Who does the intraoral scanning?  Write name and position 
    Who takes the CBCT and Xrays?  Write name and position 

📋 Action:
Complete the subtasks below:

Checklist:
☐ ⭐ Write your answers about the DRIs above
☐ ⭐ Are these people trained and know what to do?', null, null, 'todo', 2000) on conflict (id) do nothing;
insert into public.tasks (id, campaign_id, parent_id, section_id, title, description, assignee_id, due_date, status, position) values ('7f02eac0-7179-5ac0-9505-a5415a417b33', 'bba38802-10d5-5192-920e-9e4869db49bb', 'ec76bec1-7c68-5e4a-afd2-e4c21b8b5fdd', null, 'Identify the DSD Patients', 'Principle 3: The 1st Appointment

Identifying the DSD Patient: Your First Step to Meaningful Dentistry


Every DSD journey begins with one essential action: recognizing who the DSD Patient is.

This is not about choosing only “perfect” or “esthetic” cases: it’s about learning to identify the people who are ready for a deeper, more personalized dental experience. People who want to be heard, understood, and guided. People who are curious, motivated, and open to transformation.

By learning how to recognize, approach, and inspire the right patients from the very first contact, you create differentiation, build trust, and increase the chances of a powerful first appointment.

🎯 Goals for this action item:
    Understand the profile and mindset of a DSD Patient
    Learn how to interact with new patients using a DSD perspective
    Spot new possibilities in your existing patient base
    Master the right verbiage and approach, using DSD campaigns to confidently start the conversation

📣 This is a team effort. Everyone (everyone!) should feel confident and aligned in identifying and communicating with DSD Patients.

Let’s learn how to see beyond the clinical and start recognizing potential in every patient story.


⭐ Content:
https://vimeo.com/1097829258/40cd16ec72?share=copy

[image in the Asana original, not copied]



https://vimeo.com/1097863459/5d7fba9505?share=copy

[image in the Asana original, not copied]


[Document] Who is a DSD Patient 
https://docs.google.com/document/d/1_jFSrlQf6ixjY3aQ9e5mpSgiWVqVQbUPIBf3FPxRh44/edit?usp=sharing
https://docs.google.com/document/d/1qo498B3TbJ6dAC1qr0NUJ-A5aOjbo777vFePRiGb6vc/edit?usp=sharing
https://docs.google.com/document/d/1QFDCAxC7kfWu88gSrMOP81uecLWYBMLYFQ3vwa2rtY0/edit?usp=sharing
https://docs.google.com/document/d/1H09HxHlRZzAUxVFhpSpjIi8yRzgOGimQg_XC99lENTc/edit?usp=sharing

[Document] Recognizing DSD Patients from the Very First Interaction
https://docs.google.com/document/d/1aZfGwwXFEg4B-It19SnBJN2Uoc3ht3a_QbQICVs6lRk/edit?usp=sharing
https://docs.google.com/document/d/19IRAhglia1YcvH8fuJ58J5iWgh4Js9e4z0xXCVd9ze8/edit?usp=sharing
https://docs.google.com/document/d/1J7KWU2C9GQNaA6lBFLxTnNXVdjbgdh9TVqeSTWipKCY/edit?usp=sharing
https://docs.google.com/document/d/1-aPvIrcr9kc7rabZMejp9XI7butqcMCdZMpxNJnts9M/edit?usp=sharing

🔄 Extra Content/Suggestions (not mandatory!):
As many times our first interactions with a new patient happen the phone or virtually is so important to talk about phone skills.
 Listen to https://www.allstardentalacademy.com/dental-training/great-call-process-overview/from All-Star Dental Academy 
 *DSD is not affiliated with All-Star Dental Academy
https://vimeo.com/679192479/5a54d797cc?share=copy

🧠 Reflection: 
    What qualities or attitudes have you noticed in patients who respond well to the DSD experience?
    Reflect on what made those cases special—was it their mindset, motivation, trust, or emotional engagement?
    Are all team members in your clinic confident in recognizing and approaching potential DSD Patients?
    Think about whether everyone—front desk, assistants, clinicians—knows what to look for and how to start the right kind of conversation.
    How could shifting your focus from “clinical cases” to “patient stories” change the way you communicate and connect with people?
    Consider the impact of leading with curiosity, empathy, and inspiration rather than procedures and problems.

📋 Action:
Complete the subtasks below:

Checklist:
☐ ⭐ Watch the [Video] Who is a DSD Patient?
☐ ⭐ Watch the [Video] Recognizing DSD Patients from the Very First Interaction
☐ ⭐ Read the [Document] ''Who is a DSD Patient''
☐ ⭐ Read the [Document] ''Recognizing DSD Patients from the Very First Interaction''
☐ [Watch] and/or [Read] the Extra Content/Suggestions (not mandatory!)', null, null, 'todo', 3000) on conflict (id) do nothing;
insert into public.tasks (id, campaign_id, parent_id, section_id, title, description, assignee_id, due_date, status, position) values ('7d9b041e-c383-5b0e-a8b1-311eb7892ccb', 'bba38802-10d5-5192-920e-9e4869db49bb', 'ec76bec1-7c68-5e4a-afd2-e4c21b8b5fdd', null, 'The DSD 1st Appointment', 'Principle 3: The 1st Appointment

The first appointment is more than just a consultation: it’s your best opportunity to make a lasting impression and show patients that your clinic offers something truly different.


Once you’ve identified a DSD Patient, your next step is to clearly communicate what this first appointment includes, why it’s special, and how it brings value to the patient.

You’ll also build a step-by-step checklist that outlines the entire journey, from the patient’s arrival to the emotional presentation and follow-up, ensuring consistency and excellence across your team.

🎯 Goals for this action item:
    Define the right verbiage to explain the DSD First Appointment with clarity and enthusiasm
    Understand in detail what happens during the first appointment, to feel confident and aligned as a team
    Reflect on the role of each team member and how they interact with the patient throughout the visit
    Create a practical checklist of steps and touchpoints that reflect the DSD Clinic standard of care
    Ensure the team is trained and ready to delegate tasks effectively, based on each person’s role and strengths

This is where the DSD experience truly begins. Let’s make it unforgettable.

⭐ Content:
https://vimeo.com/816957588/0a704e277c?share=copy

[image in the Asana original, not copied]



https://vimeo.com/1097829409/948ad8c9fd?share=copy

[image in the Asana original, not copied]


[Document] Patient Expectations, Desires & Concerns –  Smile Design Questionnaire

https://docs.google.com/document/d/1Z2StMVb9AqWTkh7QDjFW-11SHOyXAx0MvKDezoHumqU/edit?usp=sharing
https://docs.google.com/document/d/1FXInpLzMvcrOwnY-GD-_JYKgGJzqk8whwPRIF3C-PyM/edit?usp=sharing
https://docs.google.com/document/d/1JOLHS9rU7vPZkqOrOzV__QF-vrme7N4ASqVqGeD6-xU/edit?usp=sharing
https://docs.google.com/document/d/1mldxL0-Kztw9MOzCX1FixvM6OqKbKfRJ41_O_2b2ZAk/edit?usp=sharing


[Document]

[image in the Asana original, not copied]


https://3439767.fs1.hubspotusercontent-na1.net/hubfs/3439767/FINAL%20WORKBOOK%20DSD%20TEAM%20CONSULTANCY%20(GERMAN).pdf
https://3439767.fs1.hubspotusercontent-na1.net/hubfs/3439767/Espa%C3%B1ol.%20WORKBOOK%20DSD%20TEAM%20CONSULTANCY%20(dragged).pdf 
https://3439767.fs1.hubspotusercontent-na1.net/hubfs/3439767/ITALIANO%201st%2c%202nd%20APP%20%2B%20Interconsultation.pdf



🧠 Reflection:
    What makes your DSD 1st appointment truly different from a regular consultation? Reflect on the elements that create emotional impact during the visit—was it the environment, the storytelling, the mock-up, or the way the team connected with the patient?
    Are all team members aligned and confident about their role in the first appointment? Think about whether each person—from the front desk to the clinician—knows what’s expected, how to contribute, and how to deliver a seamless experience.
    How could having a clear checklist improve consistency and patient trust during this visit?Consider the benefits of having a defined, step-by-step process that helps every team member stay focused, confident, and intentional throughout the appointment.

📋 Action:
Complete the subtasks below:

Checklist:
☐ ⭐ Watch [Video] ''DSD 1st Appointment Protocol''
☐ ⭐ Watch the [Video] ''Patient Expectations, Desires & Concerns''
☐ ⭐ Read the [Document] ''Patient Expectations, Desires & Concerns –  Smile Design Questionnaire''
☐ ⭐ Read the [Document] DSD 1st Appointment Checklist
☐ Create Your Own Detailed Checklist for the DSD First Appointment. Upload your checklist to this task', null, null, 'todo', 4000) on conflict (id) do nothing;
insert into public.tasks (id, campaign_id, parent_id, section_id, title, description, assignee_id, due_date, status, position) values ('ce337722-b7af-5d5e-821f-3113315174c0', 'bba38802-10d5-5192-920e-9e4869db49bb', 'ec76bec1-7c68-5e4a-afd2-e4c21b8b5fdd', null, 'Step By Step. How to perform a Complete DSD 1st Appointment', 'Principle 3: The 1st Appointment

Let’s bring the DSD 1st Appointment to life.


Now it’s time to put everything into practice by doing a real DSD 1st Appointment with a patient.

You don’t need to document every detail of the visit—but please share the photos and video from the DSD photo/video protocol so your DSD Coach can review and give you personalized feedback.

You can send the material in the way that’s easiest for you: by email, WhatsApp, Planning Center, or whichever method your team prefers.

The goal is to make sure everything looks great and follows the protocol correctly: so you can feel confident and ready to repeat it with every patient.

⭐ Content:
[Document] ''How to Capture the DSD Photo and Video Protocol''

https://3439767.fs1.hubspotusercontent-na1.net/hubfs/3439767/DSD_Documentation_Protocol_ENGLISH.pdf
https://3439767.fs1.hubspotusercontent-na1.net/hubfs/3439767/DSD_Documentation_Protocol_GERMAN.pdf.pdf
https://3439767.fs1.hubspotusercontent-na1.net/hubfs/3439767/DSD_Documentation_Protocol_ESPA%C3%91OL.pdf.pdf
https://3439767.fs1.hubspotusercontent-na1.net/hubfs/3439767/DSD_Documentation_Protocol_ITALIANO.pdf.pdf


⭐  Photo Protocol Content:
https://vimeo.com/942255874/cecde7b1d1?share=copy

[image in the Asana original, not copied]


https://vimeo.com/942255561/279cfa4375?share=copy

[image in the Asana original, not copied]


https://vimeo.com/942255533/89a96d2a2b?share=copy

[image in the Asana original, not copied]


https://vimeo.com/942255482/215740b204?share=copy

[image in the Asana original, not copied]


https://vimeo.com/942255253/1a7dff4cbe?share=copy

[image in the Asana original, not copied]





⭐  Video Protocol Content:
https://vimeo.com/942255218/316940bb4b?share=copy

[image in the Asana original, not copied]


https://vimeo.com/942255038/374c565147?share=copy

[image in the Asana original, not copied]


https://vimeo.com/942254973/6c3662da4d?share=copy

[image in the Asana original, not copied]





⭐ STL+CBCT Content:
https://vimeo.com/942254897/ee696c66f4?share=copy

[image in the Asana original, not copied]


https://vimeo.com/942260494/0406eecf13?share=copy

[image in the Asana original, not copied]



🧠 Reflection:
    What went well during your first complete DSD 1st appointment with a real patient? Reflect on the moments that felt smooth, well-prepared, or emotionally impactful—for the team and the patient. What parts of the workflow felt aligned with the DSD vision?
    How confident do you feel capturing the full DSD photo and video protocol? Was the process clear and coordinated among team members? Is there anything technical, logistical, or teamwork-related that could be improved for next time?
    How did the patient respond to the overall experience—and what did you learn from their reaction? Think about their emotional engagement, body language, and feedback. Did this reinforce the importance of this first appointment? What will you do differently or repeat moving forward?

📋 Action:
Complete the subtasks below:

Checklist:
☐ ⭐ Read the [Document] ''How to Capture the DSD Photo and Video Protocol''
☐ ⭐ Watch the [Videos] in the section ''Photo Protocol Content'' (5 videos)
☐ ⭐ Watch the [Videos] in the section: ''Video Protocol Content'' (3 videos)
☐ ⭐ Watch the [Videos] in the section: ''STL + CBCT Content'' (2 videos)
☐ ⭐ Share the photo/video protocol of the DSD 1st Appointment for 1 patient with your DSD Coach (via email, WhatsApp, Planning Center, or Asana—whichever works best for you)', null, null, 'todo', 5000) on conflict (id) do nothing;
insert into public.tasks (id, campaign_id, parent_id, section_id, title, description, assignee_id, due_date, status, position) values ('cd1b1b0b-84ed-5391-b77d-06efb31a7910', 'bba38802-10d5-5192-920e-9e4869db49bb', 'ec76bec1-7c68-5e4a-afd2-e4c21b8b5fdd', null, 'Create a ''Welcome Document'' to Prepare your Patients', 'Principle 3: The 1st Appointment

Create a “What to Expect” Document for New Patients


A clear and friendly document that explains what patients can expect from your clinic and team—as well as what will happen during their first DSD appointment—is a powerful way to connect with them, even before they walk through the door.

Sharing this type of content ahead of time helps patients feel informed, calm, and confident about choosing your clinic. It reduces anxiety, builds trust, and shows that you care about their experience from the very beginning.

This document can be sent after a phone call, through WhatsApp, email, or as part of an automated welcome sequence. 
It’s especially helpful for first-time visitors who don’t yet know you—but want to feel reassured about who you are, how you work, and what your values are.

🧡 It’s a chance to:
    Introduce your team and your clinic environment
    Show your purpose and human side
    Explain how the appointment works step by step
    And help patients see the value of what you offer before they arrive

The goal is simple: to make every patient feel welcomed, prepared, and excited to begin their journey with you.

⭐ Content:
https://3439767.fs1.hubspotusercontent-na1.net/hubfs/3439767/1st%20Appointment%20Guide%20by%20Howard%20Gluckman.pdf 🇬🇧 (only English)

[Document] Sample Document Text: What to Expect During Your DSD Journey

https://docs.google.com/document/d/1dtiYSqAtEG7s7HYwG97KknwxPxbkHRCZk-AifVVvxKo/edit?usp=sharing
https://docs.google.com/document/d/1Fp0RHLhdnls_MkT3hN_sNiWwzWjiJf2joC6LK2pAL9g/edit?usp=sharing
https://docs.google.com/document/d/1pV5dY0Gyv6wiKUnUfNCRAZShVgvAHS3Iu4aEC9DYrUs/edit?usp=sharing
https://docs.google.com/document/d/1unH6OH_a-ebN2ftKIuyWFtZ-TwIMHOIN9TeO6_iw4OQ/edit?usp=sharing

🧠 Reflection:
    What emotions do you want your patient to feel after reading this document—reassured, excited, calm, understood?
    Think about the tone and content you need to include to evoke those feelings.
    If you were a new patient visiting your clinic for the first time, what questions or doubts would you have?
    Use this perspective to guide what you explain, show, and highlight.
    How can this document reflect not just what you do, but who you are as a team and what you stand for?
    This is more than a checklist—it’s a chance to build trust, connection, and clarity from the start.

📋 Action:
Complete the subtasks below:

Checklist:
☐ ⭐ Read the [Document] ''1st Appointment Guide by Howard Gluckman''
☐ ⭐ Read the [Document] ''Sample Document Script: What to Expect During Your DSD Journey''
☐ ⭐ Create a Patient Welcome Document, using the Guide by Dr. Howard Gluckman and the DSD Script as references.
☐ ⭐ Create a Second Document that explains what will happen during the 1st and 2nd Appointments.', null, null, 'todo', 6000) on conflict (id) do nothing;
insert into public.tasks (id, campaign_id, parent_id, section_id, title, description, assignee_id, due_date, status, position) values ('9a057293-1ab3-5d74-95c3-89eeb2f9011b', 'bba38802-10d5-5192-920e-9e4869db49bb', 'ec76bec1-7c68-5e4a-afd2-e4c21b8b5fdd', null, 'Record a Video of the Practice Explaining to Patients ''What to Expect''', 'Principle 3: The 1st Appointment

Record a welcome video to introduce the Patient Experience


Creating a short video that explains what patients can expect during their visit is a powerful way to build trust before they even walk through the door.

This video helps you set the tone, reduce uncertainty, and make patients feel more comfortable and excited about their upcoming appointment.

It also allows you to highlight what makes your clinic and the DSD experience different—right from the start.
The goal is to remove any doubts, answer common questions, and make your patients feel truly welcomed.

🔹 A professional video is recommended, but it’s NOT mandatory. 
If you prefer to do a more casual, homemade version, that’s totally fine! It’s a great opportunity to practice your message and see what works—so that later, if you decide to create a professional version, you’ll already have a clear structure and tone in mind.
The goal is to remove any doubts, answer common questions, and make your patients feel truly welcomed.

⭐ Content:
https://youtu.be/oPVRyOLPW4Q?si=V9y8Nz3utM2ApHmQ 

https://qr2.mobi/1txrk

[Document] Sample Video Script: What to Expect During Your DSD Journey

https://docs.google.com/document/d/1Kg1N0ikBbM32lXQFclywJeHv0gsO1YrPNrbPAi0s5UA/edit?usp=sharing
https://docs.google.com/document/d/1S89VByYTzLC9FNoTRNOENCIevy584N1nVQGU4dfWwfI/edit?usp=sharing
https://docs.google.com/document/d/13DlLsMZJdwwp9ekBOuouarf4naGt0mtwA07xiwwKI7Y/edit?usp=sharing
https://docs.google.com/document/d/1GJahmEt2ckYmdgaZdqV1zeSZe_gjgN654BkIcijOMD4/edit?usp=sharing

🧠 Reflection:
    What emotions do you want your patient to feel after watching this video—reassured, excited, calm, understood?
    Think about the tone and content you need to include to evoke those feelings.
    If you were a new patient visiting your clinic for the first time, what questions or doubts would you have?
    Use this perspective to guide what you explain, show, and highlight.
    How can this video reflect not just what you do, but who you are as a team and what you stand for?
    This is more than a checklist—it’s a chance to build trust, connection, and clarity from the start.

📋 Action:
Complete the subtasks below:

Checklist:
☐ ⭐ Watch the [Videos] from Well Clinic and Dental Bar (2 videos)
☐ ⭐ Read the [Document] ''Sample Video Script: What to Expect During Your DSD Journey''
☐ Record a video where someone from your team explains to patients what to expect during their first DSD appointment. You can either:
🔹 Make a simple version (as a team) with your phone to practice and refine your message (this is a great first step),
or
🔹 Hire a professional videographer to produce a polished, final version for your website or patient communication.', null, null, 'todo', 7000) on conflict (id) do nothing;
insert into public.tasks (id, campaign_id, parent_id, section_id, title, description, assignee_id, due_date, status, position) values ('b49a95b0-3c75-5269-86ea-0df9b723d58c', 'bba38802-10d5-5192-920e-9e4869db49bb', 'ec76bec1-7c68-5e4a-afd2-e4c21b8b5fdd', null, 'DSD 1st Appointment scripts', 'DSD 1st Appointment Scripts 

A practical guide with real examples of how to communicate with different types of patients during the first visit. 

It helps you handle common situations such as enthusiasm, skepticism, anxiety, frustration, or indecision. 

The goal is to respond with empathy, professionalism, and confidence while keeping the conversation positive and constructive. Use it as a reference and practice these scenarios as a team to improve communication skills and consistency.

[Document] DSD 1st Appointment scripts

https://docs.google.com/document/d/1_wvQQva0esSoIGlVrnL4fSjEtsxtcYMaZ-Z4mvJ-pCE/edit?usp=sharing
https://docs.google.com/document/d/1arPZmA-qonE08yRqMjh7AvdGtm-eQIiPmrqw7wVJUiU/edit?usp=sharing
https://docs.google.com/document/d/1mY_F1jY3niTD_FEUroWAGLE7zCsxYV4AmrcHlk-IU-M/edit?usp=sharing
https://docs.google.com/document/d/1ARbFO3eAQqxsIgsAU_TL0lImWc1QQf3xkxWzekZkDm8/edit?usp=sharing 


📋 Action:
Complete the subtasks below:

Checklist:
☐ ⭐ Read the [Document] ''Scripts''. Use it as a team to get inspired, gather communication resources and ideas, or even practice role plays together to handle objections, challenging conversations, and tricky questions or answers', null, null, 'todo', 8000) on conflict (id) do nothing;
insert into public.tasks (id, campaign_id, parent_id, section_id, title, description, assignee_id, due_date, status, position) values ('79ce703a-cb20-51ab-972e-b879f4091560', 'bba38802-10d5-5192-920e-9e4869db49bb', null, '98bf2aa5-6a56-5a4e-b3c2-094e6302b20c', 'Principle 4: The DSD Inter-Consultation [The Workflow]', null, null, null, 'todo', 8000) on conflict (id) do nothing;
insert into public.tasks (id, campaign_id, parent_id, section_id, title, description, assignee_id, due_date, status, position) values ('f0722ff8-fca9-55b3-a989-a87df71642d7', 'bba38802-10d5-5192-920e-9e4869db49bb', '79ce703a-cb20-51ab-972e-b879f4091560', null, '🎯 Principle 4 standards', 'Principle 4: Inter-Consultation [The Workflow]


The Core of DSD Scorecard standards: 
"Our team adheres to a structured patient/case management process, ensuring seamless preparation for treatment plans and case presentations."

Checklist:
☐ We have defined workflows and use task management tools for accountability, efficient internal communication, and tracking/managing DSD cases. The team is trained to handle non-dentist functions (photography, scanning, x-rays/CBCT, Emotional Presentation, mock-up preparation, etc.), allowing for seamless delegation.
☐ The DSD Coordinator efficiently processes all necessary patient files for the patient’s mock-up and treatment plan presentation, ensuring the steps needed until the patient’s second appointment are delivered on time as planned.
☐ Our DSD Coordinator is accountable for the communication with the DSD Planning Center, facilitating the doctor and specialists (if applicable) connection in discussing the patient’s ideal treatment.
☐ We have a success rate in our patient management of 90%. We track routinely to avoid delays on our side, errors with the products or services, and miscommunication.', null, null, 'todo', 1000) on conflict (id) do nothing;
insert into public.tasks (id, campaign_id, parent_id, section_id, title, description, assignee_id, due_date, status, position) values ('d503c506-3d9d-54b7-b3ed-bfa33505cddb', 'bba38802-10d5-5192-920e-9e4869db49bb', '79ce703a-cb20-51ab-972e-b879f4091560', null, 'Assign the DRIs (Direct Responsible Individual) for every DSD Inter-Consultation task', 'Principle 4: Inter-Consultation [The Workflow]

For a successful DSD implementation, clear roles and responsibilities are key—especially when introducing new workflows like the DSD Inter-Consultation.


Each step of this process requires coordination between different team members, and assigning a Directly Responsible Individual (DRI) to each task helps ensure everything gets done efficiently and on time.

Even in small teams where some people handle multiple responsibilities, it''s still important to define and document who does what. This creates clarity, avoids confusion, and helps the team stay aligned.

Use this task to discuss and write down who is responsible for each step of the DSD Inter-Consultation workflow in your clinic.

This will support better delegation, highlight training needs, and strengthen your team’s collaboration.

    Who organizes all the patient files (Photos, Video, CBCT, X-rays, Case Notes) in a folder/cloud system and makes it accessible for everyone? Write name and position 
    Who sends all these files to the DSD Planning Center? Write name and position 
    Who takes care of the smile design approval? Write name and position 
    Who takes care of the communication between the Specialists and the Planning Center? Whose email is added to receive the notifications in order to be able to inform the doctor about them? Write name and position 
    Who prints the model/Shell for the Mockup or orders it to the Planning Center or to your local Lab? Write name and position 
    Who manufactures the Silicone index /orders it to the Planning Center or to your local Lab? Write name and position 
    Who starts the first part of the Emotional Presentation that can already be prepared before the patient comes to the second visit? Write name and position 
    Who puts the Treatment plan script and options together with the financial proposal in order to present them to the patient? Write name and position 

📋 Action:
Complete the subtasks below:

Checklist:
☐ ⭐ Write your answers about the DRIs above
☐ ⭐ Are these people trained and know what to do?', null, null, 'todo', 2000) on conflict (id) do nothing;
insert into public.tasks (id, campaign_id, parent_id, section_id, title, description, assignee_id, due_date, status, position) values ('c91376db-6747-5269-ad54-0e619470271c', 'bba38802-10d5-5192-920e-9e4869db49bb', '79ce703a-cb20-51ab-972e-b879f4091560', null, 'The DSD Inter-Consultation', 'Principle 4: Inter-Consultation [The Workflow]



The DSD Inter-Consultation

As Dr. Christian Coachman says, “this is the core of the core of DSD.”

The DSD Inter-Consultation is the behind-the-scenes process where everything comes together. It’s what allows the DSD 2nd Appointment—the emotional and clinical turning point of the DSD Journey—to be clear, confident, and impactful for the patient.

To make this happen, your team must follow a structured workflow that includes planning, coordination, documentation, and alignment among all involved.

This task is about mastering the key steps of the Inter-Consultation, assigning responsibilities, and ensuring nothing is missed—so that when the patient returns for their DSD 2nd Appointment, everything is prepared to deliver a truly unforgettable experience.

⭐ Content:
https://vimeo.com/817195360/4e9d010367?share=copy

[image in the Asana original, not copied]


[Document] The interconsultation

[image in the Asana original, not copied]


https://3439767.fs1.hubspotusercontent-na1.net/hubfs/3439767/FINAL%20WORKBOOK%20DSD%20TEAM%20CONSULTANCY%20(GERMAN)%20(1).pdf
https://3439767.fs1.hubspotusercontent-na1.net/hubfs/3439767/AGOSTO%20FINAL%20WORKBOOK%20DSD%20TEAM%20CONSULTANCY%20(SPANISH).pdf
https://3439767.fs1.hubspotusercontent-na1.net/hubfs/3439767/ITALIANO%201st%2c%202nd%20APP%20%2B%20Interconsultation%20%20(1).pdf

🧠 Reflection:
    What systems do you have in place to ensure that everyone is aligned before the DSD 2nd Appointment?Reflect on whether your internal preparation process guarantees that all team members—especially clinicians and treatment coordinators—are updated, aligned, and ready to deliver a clear, confident, and emotionally compelling presentation.
    Are the responsibilities of each team member during the DSD Inter-Consultation clearly defined and consistently followed? Think about how you assign tasks like treatment plan review, document preparation, and coordination with the DSD Planning Center. Is everyone aware of their role, or are there areas where responsibility is vague or overlapping?
    Do you rehearse or review the full patient case before the DSD 2nd Appointment? Consider whether your team reviews both the clinical and emotional aspects of the case before seeing the patient again. What could be done to elevate the clarity, flow, and emotional impact of the DSD 2nd Appointment?

📋 Action:
Complete the subtasks below:

Checklist:
☐ ⭐ Watch [Video] ''The key steps of the DSD Inter-Consultation''
☐ ⭐ Read the [Document] DSD Interconsultation Checklist', null, null, 'todo', 3000) on conflict (id) do nothing;
insert into public.tasks (id, campaign_id, parent_id, section_id, title, description, assignee_id, due_date, status, position) values ('eb81258a-fc64-5975-990d-3e27dd5dee61', 'bba38802-10d5-5192-920e-9e4869db49bb', '79ce703a-cb20-51ab-972e-b879f4091560', null, 'Learn the DSD Planning Center Basics', 'Principle 4: Inter-Consultation [The Workflow]



Learn the DSD Planning Center basics

The DSD Planning Center is your clinic’s partner for digital design and interdisciplinary planning.

In this task, you’ll get familiar with how it works, what it offers, and how to start submitting your first cases with clarity and confidence.

Understanding the basics will help your team collaborate better, avoid mistakes, and get the most value from the service.

⭐ Content:
    https://vimeo.com/942247981/b2d382552a?share=copy
    https://vimeo.com/941164924/b70ab4f0c4?share=copy
    https://vimeo.com/941175657/14c142a74f?share=copy 
    https://vimeo.com/941175628/e9f96d2370?share=copy 
    https://vimeo.com/942255848/bf5c08c84d?share=copy 
    https://vimeo.com/941179744/3bb4b0dba6?share=copy
    https://vimeo.com/938100736/9e87520128?share=copy
    https://vimeo.com/941175608/e460d336c8?share=copy 
    https://vimeo.com/941166878/b007912145?share=copy
    https://vimeo.com/941175568/886c228bd3?share=copy
    https://vimeo.com/941182408/7cf449b73d?share=copy
    https://vimeo.com/938116552/a908ed9b55?share=copy 
    https://vimeo.com/938108113/bd08700469?share=copy
    https://vimeo.com/939044292/89e777b391?share=copy

🧠 Reflection:
    Do you all fully understand the role of the DSD Planning Center in your clinic’s workflow? Reflect on whether your team clearly understands how the Planning Center supports your designs, interdisciplinary planning, and patient outcomes—or if it still feels like a separate or external step.
    Who in your team is responsible for communicating with the DSD Planning Center and submitting cases?Think about whether roles and responsibilities are clearly assigned for case submission, follow-up, and communication. Is this process consistent and efficient, or does it still need more clarity?
    Are you using all the tools and resources offered by the DSD Planning Center to their full potential?Consider if you’re truly taking advantage of the Planning Center’s expertise—using the right case types, providing complete documentation, and reviewing feedback carefully to improve your next submissions.

📋 Action:
Complete the subtasks below:

Checklist:
☐ ⭐ Watch the [Videos] located in the Content section (14 videos)', null, null, 'todo', 4000) on conflict (id) do nothing;
insert into public.tasks (id, campaign_id, parent_id, section_id, title, description, assignee_id, due_date, status, position) values ('e8a8e2e0-227c-521e-8a92-6ea453b4fb91', 'bba38802-10d5-5192-920e-9e4869db49bb', '79ce703a-cb20-51ab-972e-b879f4091560', null, 'Prepare for the Motivational Mock-Up', 'Principle 4: Inter-Consultation [The Workflow]

Prepare for the Motivational Mock-Up


Once the Inter-Consultation is complete and your digital plan is ready, it’s time to prepare the mock-up—a key step for creating an emotional and visual impact during the second appointment.

There are three main options for bringing the mock-up (Shell or Bisacryl) to life, depending on your clinic’s resources and preferences:

    Order it directly from the DSD Lab for professional design and manufacturing.
    Print it in-house, if your clinic has a 3D printer and the proper protocols in place.
    Download the .STL files of the selected mock-up type and send them to a trusted local lab for fabrication.


Each option can work well—as long as the workflow is clear, and the team knows who is responsible for each step.
Let’s make sure everything is ready before the patient returns for their emotional presentation.


⭐ Content:
https://vimeo.com/846944919/ef0a1208c8?share=copy

[image in the Asana original, not copied]



https://vimeo.com/846944971/9a12a1065c?share=copy

[image in the Asana original, not copied]



https://vimeo.com/846945041/d9706f7034?share=copy

[image in the Asana original, not copied]



🔄 Extra Content/Suggestions (not mandatory!):
https://vimeo.com/999544041/f6231fb0c1?share=copy

🧠 Reflection:
    Have you decided where and how your mock-ups will be manufactured? Reflect on whether your clinic will use in-house 3D printing, send files to your local lab, or order directly from the DSD Lab—and what influenced that decision.
    Who is in charge of the mock-up preparation workflow? Think about who will manage the communication with your lab or oversee the in-house manufacturing, and whether this person has clear instructions and full control of the timeline.
    Do you have all the necessary materials and tools under control? Review if your team knows how to prepare the silicone index, and if you''re fully stocked with the materials you’ll need: printed resin, bisacryl, flow composite, pink composite, black marker, putty and light-body silicone, scalpel, etc. Even if manufacturing is outsourced, being prepared internally is essential for last-minute needs or quality checks.

📋 Action:
Complete the subtasks below:

Checklist:
☐ ⭐ Watch [Video] Silicone Index Materials
☐ ⭐ Watch [Video] Manufacturing the Silicone Index
☐ ⭐ Watch [Video] Cutting the Silicone Index
☐ [Watch] and/or [Read] the Extra Content/Suggestions (not mandatory!)', null, null, 'todo', 5000) on conflict (id) do nothing;
insert into public.tasks (id, campaign_id, parent_id, section_id, title, description, assignee_id, due_date, status, position) values ('136d2119-0751-5614-8bb2-2796dd40ee28', 'bba38802-10d5-5192-920e-9e4869db49bb', null, '98bf2aa5-6a56-5a4e-b3c2-094e6302b20c', 'Principle 5: The DSD Inter-Consultation [Treatment Planning with the Planning Center]', null, null, null, 'todo', 9000) on conflict (id) do nothing;
insert into public.tasks (id, campaign_id, parent_id, section_id, title, description, assignee_id, due_date, status, position) values ('1ddb6c62-5912-517f-8cc6-d326bc392d6d', 'bba38802-10d5-5192-920e-9e4869db49bb', '136d2119-0751-5614-8bb2-2796dd40ee28', null, '🎯 Principle 5 standards', 'Principle 5: The DSD Inter-Consultation [Treatment Planning]


The Core of DSD Scorecard standards: 
"We collectively plan our cases with the DSD Planning Center, prioritizing comprehensive ideal treatment plan options tailored to the individual patient''s needs."

Checklist:
☐ We effectively communicate with the DSD Planning Center the desired deadlines, patient expectations, and case turnaround time to avoid miscommunications and delays.
☐ We guide the designers to consider the patient’s clinical needs as we observe and discuss with the patient, so our patient’s designs are ideally planned.
☐ We collaborate with our specialists and DSD doctors taking advantage of the planning sessions and DSD visuals to ensure the treatments are guided and agreed upon presenting.
☐ All our cases have a comprehensive and interdisciplinary approach, if necessary, to ensure that we offer the patient the ideal less invasive treatment. We provide a detailed view of each case, instilling trust and confidence in patients to make an informed decision.', null, null, 'todo', 1000) on conflict (id) do nothing;
insert into public.tasks (id, campaign_id, parent_id, section_id, title, description, assignee_id, due_date, status, position) values ('5e5cb30c-0f66-5358-81c6-6e69fbba4c4d', 'bba38802-10d5-5192-920e-9e4869db49bb', '136d2119-0751-5614-8bb2-2796dd40ee28', null, 'The DSD Planning Center Case Report', 'Principle 5: The DSD Inter-Consultation [Treatment Planning]



The DSD Planning Center Case Report

Between the first and second appointments lies a crucial internal step: the Inter-Consultation.

This is when your team finalizes the treatment proposal using the DSD Planning Center report—a moment that transforms inspiration into a real plan.

Understanding how to read, interpret, and present the Planning Center report is essential. It allows you to guide your patients through the proposed treatment in a way that is clear, visual, and meaningful.

This document isn’t just for dentists—it’s a tool to build patient understanding, trust, and commitment. It connects the clinical and emotional journey, making sure patients don’t feel lost or overwhelmed, but supported and informed.

In this task, you’ll review how your team is currently using the Planning Center report and how you can improve communication, alignment, and patient experience during this phase.

You’ll also reflect on how this step can become more collaborative and interdisciplinary, involving key team members beyond just the dentist.

Let’s make sure this moment isn’t just technical—but strategic, empathetic, and effective.


⭐ Content:
https://vimeo.com/941182408/7cf449b73d?share=copy

[image in the Asana original, not copied]



https://vimeo.com/938116552/a908ed9b55?share=copy

[image in the Asana original, not copied]



https://vimeo.com/938108113/bd08700469?share=copy

[image in the Asana original, not copied]


🧠 Reflection:
    How confident do you feel when reviewing and interpreting the DSD Planning Center report? Think about whether the report feels clear and actionable for your team—or if there are moments of confusion that could be improved with better understanding or communication.
    Is your team using the report collaboratively or is it only reviewed by one/the dentist? Consider if Associates or other team members are included in the planning process. Could their involvement make the experience more unified and effective for the patient?
    How do you currently present the information from the report to the patient in the DSD 2nd appointment?Reflect on whether the explanation is visual, simple, and emotionally engaging—or if there’s room to make the presentation feel more patient-friendly and connected to their goals.

📋 Action:
Complete the subtasks below:

Checklist:
☐ ⭐ Watch the [Videos] above about DSD Planning Center case report (3 videos)', null, null, 'todo', 2000) on conflict (id) do nothing;
insert into public.tasks (id, campaign_id, parent_id, section_id, title, description, assignee_id, due_date, status, position) values ('d0b5dcb9-5fd6-5b84-ad63-781fe4202c65', 'bba38802-10d5-5192-920e-9e4869db49bb', '136d2119-0751-5614-8bb2-2796dd40ee28', null, 'Communication with the DSD Planning Center', 'Principle 5: The DSD Inter-Consultation [Treatment Planning]



Communication with the DSD Planning Center

Behind every great smile design, there’s great communication.

Working efficiently with the DSD Planning Center means more than just sending files—it requires clear, timely, and structured communication at every step of the process. This ensures that your clinical cases move forward smoothly and without unnecessary delays or misunderstandings.

Knowing when to reach out, how to formulate your messages, and what to clarify from the beginning can make a big difference in the quality of what you receive and how fast you receive it.

Whether it’s about the quality of the files, the specific expectations you have, modifications that need to be made, or feedback after receiving the proposal—your ability to communicate proactively is key to making the experience efficient and enjoyable for everyone involved.

In this task, you’ll reflect on how your team currently communicates with the Planning Center and identify ways to improve your workflow, avoid frustration, and ensure each case becomes a learning opportunity.

Let’s make this part of your workflow more efficient, more human, and more aligned with the DSD way of working.

⭐ Content:
https://vimeo.com/941175608/e460d336c8?share=copy

[image in the Asana original, not copied]



https://vimeo.com/941166878/b007912145?share=copy

[image in the Asana original, not copied]



https://vimeo.com/938637266/c60428c884?share=copy

[image in the Asana original, not copied]



https://vimeo.com/939044292/89e777b391?share=copy

[image in the Asana original, not copied]


🧠 Reflection:
    How clear and complete is your current communication with the DSD Planning Center? Reflect on whether you’re providing enough information and context with each case, or if miscommunications have caused delays, confusion, or rework.
    Do you have an internal system for who communicates with the Planning Center and how messages are managed? Think about whether the responsibility is clearly assigned and if the messages reflect your clinic’s professionalism and clarity.
    How do you use feedback from each case to improve your communication and submissions for the next one? Consider if your team reviews each case together and turns Planning Center interactions into learning moments—or if each case is treated in isolation without long-term improvement.

📋 Action:
Complete the subtasks below:

Checklist:
☐ ⭐ Watch the [Videos] about the Communication with the Planning Center (4 videos)', null, null, 'todo', 3000) on conflict (id) do nothing;
insert into public.tasks (id, campaign_id, parent_id, section_id, title, description, assignee_id, due_date, status, position) values ('52ca8bb6-2e74-512d-8ca3-5963a1ac6392', 'bba38802-10d5-5192-920e-9e4869db49bb', null, '98bf2aa5-6a56-5a4e-b3c2-094e6302b20c', 'Principle 6: The DSD 2nd Appointment [Emotional Journey]', null, null, null, 'todo', 10000) on conflict (id) do nothing;
insert into public.tasks (id, campaign_id, parent_id, section_id, title, description, assignee_id, due_date, status, position) values ('5bb82d7b-e401-5d3b-bfa8-077bf60485d2', 'bba38802-10d5-5192-920e-9e4869db49bb', '52ca8bb6-2e74-512d-8ca3-5963a1ac6392', null, '🎯 Principle 6 standards', 'Principle 6: The DSD 2nd Appointment [Wow Effect]


The Core of DSD Scorecard standards: 
"Our second appointments redefine the patient experience, offering a unique opportunity to test-drive their smiles. Patients are captivated by our Emotional Presentations, featuring images that emotionally connect them with their envisioned smiles and the transformative power of the proposed treatment."

Checklist:
☐ Our DSD Coordinator has full control and meticulously plans the second appointment. They master the personalization of the case presentation in Keynote, take high-quality emotional photography, and organize the treatment plan in the most presentable way that exceeds patient expectations.
☐ Our technique to place mock-ups considers the patient comfort and we use the latest innovations and strategies to improve the appointment experience.
☐ We keep our patients engaged during our about 90-minute second appointments. Patients leave with their treatment plan along with their Emotional Presentations in video format and photos, fostering a deeper connection with their newly improved selves and the dental team.
☐ Our focus on attention to detail from front and back teams and the office''s thought ambiance allows a differentiated patient experience for every patient, who leaves comments and reviews about their experience.', null, null, 'todo', 1000) on conflict (id) do nothing;
insert into public.tasks (id, campaign_id, parent_id, section_id, title, description, assignee_id, due_date, status, position) values ('82e71cfc-0142-5e40-b27b-fd4faed89eca', 'bba38802-10d5-5192-920e-9e4869db49bb', '52ca8bb6-2e74-512d-8ca3-5963a1ac6392', null, 'Assign the DRIs (Direct Responsible Individual) for your 2nd Appointment task', 'Principle 6: The DSD 2nd Appointment [Emotional Journey]

When implementing a new workflow, it’s essential that everyone on the team knows what is expected of them during each step—especially in such an emotionally important moment as the Smile Test Drive!


The goal is not for one person to do everything, but to ensure that each task is clearly assigned, properly delegated, and supported by the right training. In smaller clinics, some roles may overlap, but regardless of the setup, teamwork and clarity are key to delivering a consistent and unforgettable experience.

This principle is about making sure the second appointment becomes a coordinated, team-driven moment—one that reflects the values, quality, and emotion behind the DSD experience.

Write who takes care of the different steps of the 2nd appointment in your team: 

    Who takes the Photos and Video BEFORE placing the Mockup? Write name and position 
    Who places the Mockup? Write name and position 
    Who takes the new emotional pictures with the Mockup? Write name and position 
    Who finalizes the second part of the emotional presentation? Write name and position 
    Who takes care of the patient during the time where the presentation is finished? Who ensures the experience of the patient during this waiting time? Write name and position 
    Who presents the emotional presentation to the patient (emotional journey)? Write name and position 
    Who presents the treatment plan to the patient (problems and solutions journey)? Write name and position 
    Who presents the financials to the patient (financial journey)? Write name and position 
    Who exports the presentation into pictures/video and sends it to the patient so he/she can take it home? Write name and position 

📋 Action:
Complete the subtasks below:

Checklist:
☐ ⭐ Write your answers about the DRIs above
☐ ⭐ Are these people trained and know what to do?', null, null, 'todo', 2000) on conflict (id) do nothing;
insert into public.tasks (id, campaign_id, parent_id, section_id, title, description, assignee_id, due_date, status, position) values ('31a00620-79a3-5090-89e8-681e4e789188', 'bba38802-10d5-5192-920e-9e4869db49bb', '52ca8bb6-2e74-512d-8ca3-5963a1ac6392', null, 'The DSD 2nd Appointment', 'Principle 6: The DSD 2nd Appointment [Emotional Journey]

This is one of the most exciting and emotional moments in the entire DSD Journey: for both the patient and the team!


The second appointment, also known as the Smile Test Drive or Smile Reveal, is when the patient sees and tries their new smile for the very first time.

It’s not just a clinical step. It’s a powerful emotional experience that creates connection, surprise, joy, and trust. If done with intention, this moment becomes a memory the patient will never forget—and a turning point in their decision-making process.

For the team, it’s also a fun and rewarding experience that reminds everyone why we do what we do.
In this task, you’ll reflect on how your current second appointment works, and explore ways to transform it into a WOW moment that is consistent, team-driven, and aligned with the DSD philosophy.

Let’s make sure your patients leave this visit thinking:
“Wow… this is exactly what I’ve been looking for.”


⭐ Content:
https://vimeo.com/817201013/ea37839dfa?share=copy

[image in the Asana original, not copied]


[Document] 🇬🇧

[image in the Asana original, not copied]


https://3439767.fs1.hubspotusercontent-na1.net/hubfs/3439767/FINAL%20WORKBOOK%20DSD%20TEAM%20CONSULTANCY%20(GERMAN)-1.pdf
https://3439767.fs1.hubspotusercontent-na1.net/hubfs/3439767/AGOSTO%20FINAL%20WORKBOOK%20DSD%20TEAM%20CONSULTANCY%20(SPANISH)-1.pdf
https://3439767.fs1.hubspotusercontent-na1.net/hubfs/3439767/ITALIANO%201st%2c%202nd%20APP%20%2B%20Interconsultation%20%20(2).pdf 

🧠 Reflection:
    What are we currently doing during the DSD 2nd Appointment that creates a ''WOW'' effect—and what might be missing?
    Think about what makes this moment memorable from the patient''s perspective, not just from a clinical one.
    Is everyone in the team clear about their role before, during, and after the Smile Test Drive?
    Reflect on how task delegation, preparation, and communication could be improved to make this experience smooth and emotionally powerful.
    If you were the patient seeing your Smile Test Drive for the first time in your clinic—how would you want to be treated, welcomed, and guided?
    Use this mindset to evaluate how human, emotional, and connected your current appointment really is.

📋 Action:
Complete the subtasks below:

Checklist:
☐ ⭐ Watch [Video] ''The DSD 2nd Appointment Workflow and Emotional Dentistry''
☐ ⭐ Read the [Document] ''DSD 2nd Appointment Checklist''
☐ Create Your Own Detailed Checklist for the DSD Second Appointment. Upload your checklist to this task', null, null, 'todo', 3000) on conflict (id) do nothing;
insert into public.tasks (id, campaign_id, parent_id, section_id, title, description, assignee_id, due_date, status, position) values ('7a581602-79a6-5470-93fc-64cb8fb859c1', 'bba38802-10d5-5192-920e-9e4869db49bb', '52ca8bb6-2e74-512d-8ca3-5963a1ac6392', null, 'Learn and practice the Motivational Mock-Up technique', 'Principle 6: The DSD 2nd Appointment [Emotional Journey]



You’ve probably been placing motivational mock-ups in your clinic for years—but small details can make a big difference.


There are specific techniques and workflows that can make the process faster, smoother, and more predictable, while also improving the fit, esthetics, and emotional impact of the mock-up.

In this part of the DSD Coaching, you''ll reflect on how your team currently approaches the Smile Test Drive and explore how to refine the clinical and emotional workflow to maximize its impact.

Even experienced teams can benefit from revisiting the basics with fresh eyes—and fine-tuning these key moments can elevate the entire patient journey!

Let’s make sure your motivational mock-ups not only look great, but also help the patient feel the power of their new smile.

⭐ Content:
https://vimeo.com/817204751/7db661d8e2?share=copy

[image in the Asana original, not copied]



https://vimeo.com/817204357/aa895b5a86?share=copy

[image in the Asana original, not copied]


https://vimeo.com/1105386818/81eeb3b2b5?ts=0&share=copy

[image in the Asana original, not copied]


https://vimeo.com/817204495/4ff616bd4d?share=copy

[image in the Asana original, not copied]



[Document] About the DSD Motivational Mock-Up

https://3439767.fs1.hubspotusercontent-na1.net/hubfs/3439767/THE_COMPLETE_GUIDE_TO_THE_DSD_MOCKUP_SUCCESS_FORMULA.pdf
https://3439767.fs1.hubspotusercontent-na1.net/hubfs/3439767/THE_COMPLETE_GUIDE_TO_THE_DSD_MOCKUP_SUCCESS_FORMULA.pdf.pdf
https://3439767.fs1.hubspotusercontent-na1.net/hubfs/3439767/SPANISH%20THE_COMPLETE_GUIDE_TO_THE_DSD_MOCKUP_SUCCESS_FORMULA.pdf.pdf 🇪🇸 
https://3439767.fs1.hubspotusercontent-na1.net/hubfs/3439767/ITALIANO%20THE_COMPLETE_GUIDE_TO_THE_DSD_MOCKUP_SUCCESS_FORMULA.pdf.pdf 🇮🇹 


[Document] Quick Guide: Placement of the NEW PRINTED mock-up STENT

https://media.digitalsmiledesign.com/hubfs/DSD%20PC%20Protocols/PRINTED%20MOCK%20UP%20STENT%20-%20QUICK%20GUIDE%202025.pdf


[Document] Why the Lower DSD Motivational Mock-Up Is Not Recommended in Most Cases

https://docs.google.com/document/d/1rCknMytUsHUj6GWe7DcAVbHSAjzUEExv8B0wi74zDC0/edit?usp=sharing
https://docs.google.com/document/d/1uYvpiP5_wNUoAbj8Y8wilh7diYHrlHnKam3xMwGYRJs/edit?usp=sharing
https://docs.google.com/document/d/196YHhcnsYAtb4q08BmlugYvivyqkJDnZyf8P6SZLwWE/edit?usp=sharing
https://docs.google.com/document/d/1RWk3Y3ZZ2oifLCfcSydOP5UXZd3CaaTLjLos0L10u9I/edit?usp=sharing

🧠 Reflection:
    What specific steps in your current Motivational Mock-Up workflow could be improved to make the process faster, cleaner, or more comfortable for the patient?
    Think about materials, timing, setup, and how the team collaborates during the appointment.
    Are you intentionally creating an emotional impact during the Smile Test Drive—or is the focus mostly on the technical part?
    Reflect on how lighting, mirrors, language, and environment can amplify the patient’s emotional reaction.
    When was the last time you reviewed or adjusted your protocol for Motivational Mock-Up placement and presentation?
    Even small updates in technique or communication can make the experience more impressive and memorable.

📋 Action:
Complete the subtasks below:

Checklist:
☐ ⭐ Watch [Video] What''s the DSD Mock-up
☐ ⭐ Watch [Tutorial] How to place the DSD Bisacryl Mock-up
☐ ⭐ Watch [Tutorial] How to place the DSD Shell Mock-up
☐ ⭐ Read the [Document] ''About the DSD Motivational Mock-Up''
☐ ⭐ Read the [Document] ''Why the Lower DSD Motivational Mock-up Is Not Recommended in Most Cases''
☐ If you’ve never tested a DSD Motivational Mock-Up before, try both approaches: order a DSD Mock-Up (Bisacryl) and DSD Shell Design + Manufacturing to compare techniques and discover which best suits your patients', null, null, 'todo', 4000) on conflict (id) do nothing;
insert into public.tasks (id, campaign_id, parent_id, section_id, title, description, assignee_id, due_date, status, position) values ('c14c367f-226a-59a2-b6b9-1d23694cb845', 'bba38802-10d5-5192-920e-9e4869db49bb', '52ca8bb6-2e74-512d-8ca3-5963a1ac6392', null, 'The Emotional Photography + Video', 'Principle 6: The DSD 2nd Appointment [Emotional Journey]

Master the Emotional Photography + Video.

DSD didn’t invent mock-ups—but we redefined the way they are delivered to patients.


DSD didn’t invent mock-ups—but we redefined the way they are delivered to patients.

The real innovation lies in the approach: how we present the new smile in a way that enhances the patient experience and creates a strong emotional connection with their future, more confident self.

It’s not just about placing resin. It’s about orchestrating a powerful emotional moment—and emotional photography and video are key to capturing and amplifying that impact.
Photos and videos taken during the Smile Test Drive are not just documentation. When done with intention, they help the patient truly see themselves differently—often for the first time. These images can spark surprise, joy, and deep reflection. They become a bridge between who they are and who they can become.

In this task, you’ll reflect on how your team currently presents motivational mock-ups and how you use emotional photography and video in that process.

You’ll explore ways to emotional workflow to turn the second appointment into a true WOW moment aligned with the DSD philosophy.

Let’s make sure your patients not only look great—but also feel seen, empowered, and excited about their journey.

⭐ Content:
https://vimeo.com/1097484122/3e765405f9?share=copy

[image in the Asana original, not copied]



https://vimeo.com/846920209/449acb8e81?share=copy

[image in the Asana original, not copied]


[Document] Making Patients Feel At Ease In Front Of The Camera. Emotional Photography 

https://docs.google.com/document/d/1mQtVFVwdXqjvo3X12ulATNa6JEPbnDeZHVF06c_VdcY/edit?usp=sharing
https://docs.google.com/document/d/1zFi6nwn-rj3V7YL_8NZL-TZAOOkeMt0AT0aedO5vvHA/edit?usp=sharing
https://docs.google.com/document/d/1r1Ue_rrNlM-4fU0rKBNRi-xUzOTZy6cFfnpLeT4KyPE/edit?usp=sharing
https://docs.google.com/document/d/1_Dg8PnCck7480hg4GQsMysJOkJHWqrEgxluzAeiYM2A/edit?usp=sharing

🔄 Extra Content/Suggestions (not mandatory!):
https://vimeo.com/999541412/8b2f15dcf3?share=copy
https://vimeo.com/588769304/70d190b538?share=copy
https://media2-production.mightynetworks.com/asset/27662788/Standardize_before_and_after_mock-up_photos_and_videos_by_Reena.pdf?_gl=1*1d57az9*_ga*MTIyMTAxMjUwMi4xNjcxMDM5NzYz*_ga_T49FMYQ9FZ*MTcxNTY0NTI3NS4xODguMS4xNzE1NjQ4NzE4LjAuMC4w*_ga_NEGJ2SXNP7*MTcxNTY0NTI3Ni4xNTAuMS4xNzE1NjQ4NzE3LjguMC4w (only English 🇬🇧)

🧠 Reflection:
    How comfortable do your patients feel when the camera is on?
    Reflect on the environment, your words, and your body language—are you helping them relax and be themselves, or is the moment feeling too technical or rushed?
    Are you capturing images that truly reflect the patient’s emotions—or just documenting the teeth?
    Think about what you want the patient to feel when they see those photos and videos. Are you telling their story visually?
    What could you improve to make the photography and video session feel more human, warm, and empowering for the patient?
    Consider lighting, music, timing, and the presence of the team. Sometimes, small changes can completely transform how a patient reacts and connects with the moment.

📋 Action:
Complete the subtasks below:

Checklist:
☐ ⭐ Watch the [Video] ''Emotional Photography Tips''
☐ ⭐ Watch the [Video] ''Emotional Photography Step by Step + Examples''
☐ ⭐ Read the [Document] ''Making Patients Feel At Ease In Front Of The Camera. Emotional Photography''
☐ [Watch] and/or [Read] the Extra Content/Suggestions (not mandatory!)', null, null, 'todo', 5000) on conflict (id) do nothing;
insert into public.tasks (id, campaign_id, parent_id, section_id, title, description, assignee_id, due_date, status, position) values ('3119d661-abc7-5cf5-bb96-be1b9bc022c5', 'bba38802-10d5-5192-920e-9e4869db49bb', '52ca8bb6-2e74-512d-8ca3-5963a1ac6392', null, 'The Emotional Journey (templates and tutorials)', 'Principle 6: The DSD 2nd Appointment [Emotional Journey]



Learn how to present a DSD case - the Emotional Journey. 

Every decision we make as human beings is ultimately guided by emotion—and choosing to move forward with a treatment plan is no exception.


That’s why the Emotional Presentation is such a powerful tool in the DSD methodology. It marks the beginning of the case presentation journey, and it’s one of the most impactful contributions DSD has made to modern dentistry.

This is where the patient sees their own smile from a new perspective—through carefully chosen photos and videos that highlight their current reality and the potential for transformation. It’s not only about teeth. It’s about identity, self-image, and confidence.

In this task, you’ll learn how to structure and deliver the Emotional Presentation, and reflect on how your team currently uses emotion—not just information—to support case acceptance.

Let’s move beyond clinical facts and start connecting with what truly motivates patients to say “yes”: how they want to feel.

⭐ Content:
https://3439767.fs1.hubspotusercontent-na1.net/hubfs/3439767/DSD%20Patient%20Presentation.key DOWNLOAD HERE

https://vimeo.com/817202614/d26b6be056?share=copy

[image in the Asana original, not copied]



[Document] Building Your Emotional Presentation in Keynote

https://docs.google.com/document/d/1z6PYoVTUECMP3CPJj87dyUgosM3ICZ9QijSfEyneWS0/edit?usp=sharing
https://docs.google.com/document/d/1Vl3DOkNgRC89tXeM8jyjVpLC62ImMwggwap4Cvb5Ym0/edit?usp=sharing
https://docs.google.com/document/d/1VIGOkOSL3orW838bxehh7eRt2yODi78OcZR3bM_FPMY/edit?usp=sharing
https://docs.google.com/document/d/1UoQtd02ZUhgEUgKRWO_hI9vHfgaeudsIpJlFfy6Xu3c/edit?usp=sharing



If you’re using PowerPoint instead of Keynote, you can download the files below. Please note that some template features may not work exactly as intended in PowerPoint.
https://3439767.fs1.hubspotusercontent-na1.net/hubfs/3439767/DSD%20E%2BCF%2BTP%20template-2.pptx DOWNLOAD HERE (POWERPOINT) (only English 🇬🇧)
https://3439767.fs1.hubspotusercontent-na1.net/hubfs/3439767/Clinical%20Cases%20DSD%20E%2BCF%2BTP%20template.pptx DOWNLOAD HERE (POWERPOINT)(only English 🇬🇧)



🧠 Reflection:
    Are you presenting cases in a way that speaks to the patient''s emotions—or just to their logic?
    Reflect on whether your current presentations are focused more on clinical details than on the emotional transformation the patient is truly seeking.
    How can the Emotional Presentation become a turning point in your patient’s decision-making process?
    Think about the images, language, and narrative you use. Are they helping the patient see themselves in a new, more confident version of who they could be?
    What role does each team member play in making this moment powerful and personal for the patient?
    Consider how coordination, tone, and empathy can make this moment unforgettable and deeply motivating

📋 Action:
Complete the subtasks below:

Checklist:
☐ ⭐ Download the [Template] DSD Case Presentation Template (Emotional + Problems + Solutions)
☐ ⭐ Watch the [Tutorial] ''How to Build the Emotional Presentation''
☐ ⭐ Read the [Document] ''Building Your Emotional Presentation in Keynote. Step by Step''
☐ Practice using the template by working with photos from a past clinical case or from a team member—even if no mock-up was done. The goal is to get comfortable with the structure and flow!', null, null, 'todo', 6000) on conflict (id) do nothing;
insert into public.tasks (id, campaign_id, parent_id, section_id, title, description, assignee_id, due_date, status, position) values ('0750059c-0e47-5e4a-b62f-13d5225d2f39', 'bba38802-10d5-5192-920e-9e4869db49bb', '52ca8bb6-2e74-512d-8ca3-5963a1ac6392', null, 'Capture a Patient’s Reaction to the Emotional Presentation', 'Principle 6: The DSD 2nd Appointment [Emotional Journey]

One of the most powerful ways to communicate what Emotional Dentistry truly means is by sharing real reactions from real patients.

When appropriate, recording a patient''s emotional response during their Smile Test Drive can become a valuable piece of content—one that inspires future patients, builds trust, and showcases the human impact of your work.

Of course, this must always be done respectfully and ethically. We recommend recording the moment discreetly (if you believe it may be meaningful), and asking for permission after the appointment, once the patient has lived the experience and is more likely to feel proud and excited to share it.

These reactions are authentic, emotional, and relatable—they can become your most effective tool to explain what makes your clinic different.

In this task, you’ll reflect on how and when to record patient reactions, and how to use this content with purpose, empathy, and consent.

⭐ Content:
https://vimeo.com/1098565856/f97719950e?share=copy

https://3439767.fs1.hubspotusercontent-na1.net/hubfs/3439767/Patient%20Photo%20&%20Media%20Authorization%20Form.pdf (only English 🇬🇧)


[image in the Asana original, not copied]




[image in the Asana original, not copied]


🧠 Reflection:
    Have you ever captured a patient’s genuine emotional reaction during the Smile Test Drive?
    If yes, what was the impact? If not, what has held you back—and how could you prepare to do it respectfully and naturally?
    How could you use these authentic reactions to help future patients understand the emotional power of what you do?
    Think about moments that speak louder than words and how they could become part of your storytelling.
    What systems or habits can you create in your clinic to record, store, and ask for permission to use this type of content—without making it feel forced or invasive?
    Consider how to make this process simple, ethical, and aligned with your brand values.

📋 Action:
Complete the subtasks below:

Checklist:
☐ ⭐ Watch [Tutorial] ''How to create a video for Social Media of the patient''s reaction to the Emotional Presentation (by Molly O''Callaghan)''
☐ ⭐ Download and Read the [Template] ''Patient Image and Video Release Example Form for Marketing Use''', null, null, 'todo', 7000) on conflict (id) do nothing;
insert into public.tasks (id, campaign_id, parent_id, section_id, title, description, assignee_id, due_date, status, position) values ('a1f845e4-2b78-5bc0-bc47-0a062d0db350', 'bba38802-10d5-5192-920e-9e4869db49bb', '52ca8bb6-2e74-512d-8ca3-5963a1ac6392', null, 'DSD 2nd Appointment Scripts. Emotional Journey', 'Principle 6: The DSD 2nd Appointment [Emotional Journey]



The DSD Emotional Presentation Script.

We are comfortable with the speech we deliver during the Emotional Presentation. 


Delivering the Emotional Presentation is not about memorizing a script—it’s about understanding the message, connecting with the patient, and speaking with authenticity and purpose.

At DSD, we believe in giving you the tools, structure, and inspiration to make this moment your own—so you can communicate confidently and naturally, in a way that reflects your personality and your clinic''s values.

To support you, we’ve prepared a practical guide with notes and suggestions on what to say in each slide of the Emotional Presentation template. This resource is here to help you learn, adapt, and practice the flow—until your message feels both personal and impactful.

Start by reviewing the document below, and then reflect on how your current presentations can evolve into something truly memorable.

⭐ Content:

[Document] Emotional Presentation Script  

https://3439767.fs1.hubspotusercontent-na1.net/hubfs/3439767/UPDATED%20FILE%202.%20EP%20script%20(1).pdf
https://3439767.fs1.hubspotusercontent-na1.net/hubfs/3439767/GERMAN%20FILE%202.%20EP%20script-1.pdf
https://3439767.fs1.hubspotusercontent-na1.net/hubfs/3439767/ESPA%C3%91OL.%20EP%20script-1.pdf
https://3439767.fs1.hubspotusercontent-na1.net/hubfs/3439767/ITALIANO.%20EP%20script.pdf

DSD 2nd Appointment Scripts – Emotional Journey 
A communication guide focused on the emotional side of the second appointment. 
It presents various patient archetypes and offers ideas on how to connect, build trust, and guide each patient type through their treatment decision in an empathetic yet confident way. This tool helps your team strengthen storytelling and emotional communication during case presentations.


[Document] DSD 2nd Appointment Scripts. Emotional Journey

https://docs.google.com/document/d/1tBIzCKwMViyVeX4_bCpA2jwaoFymOaw5HIuLAlg7mks/edit?usp=sharing
https://docs.google.com/document/d/1gF2K1SYIiezhUZ6ICFoUClZE14xE5U1eSfViYtGvQXc/edit?usp=sharing
https://docs.google.com/document/d/1GHbTJZvu2KNAGysmgcTXLdJlVI6ktNv2peZHkF7SqRo/edit?usp=sharing
ITALIAN 🇮🇹

🧠 Reflection:
    Do you feel confident and natural when delivering the Emotional Presentation—or are you still relying too much on the template?
    Reflect on which parts feel fluid and which still feel scripted, and what you can do to make the message truly yours.
    Are you focusing only on what to say—or also on how the patient is feeling while you say it?
    Think about your tone, pauses, and how you create space for the patient to reflect and react emotionally.
    What parts of the Emotional Presentation resonate most with your patients—and how can you build on those moments?
    Look for clues in their expressions, body language, or questions. Use that insight to adapt your approach and make the presentation even more meaningful.

📋 Action:
Complete the subtasks below:

Checklist:
☐ ⭐ Read the [Document] ''Scripts''. Use it as a team to get inspired, gather communication resources and ideas, or even practice role plays together to handle objections, challenging conversations, and tricky questions or answers', null, null, 'todo', 8000) on conflict (id) do nothing;
insert into public.tasks (id, campaign_id, parent_id, section_id, title, description, assignee_id, due_date, status, position) values ('5f6ab7b5-c355-583f-b044-285ba65474ec', 'bba38802-10d5-5192-920e-9e4869db49bb', null, '98bf2aa5-6a56-5a4e-b3c2-094e6302b20c', 'Principle 7: DSD 2nd Appointment [Problems + Solution Journey. Case Presentation]', null, null, null, 'todo', 11000) on conflict (id) do nothing;
insert into public.tasks (id, campaign_id, parent_id, section_id, title, description, assignee_id, due_date, status, position) values ('11848e04-eac5-5511-9303-0c4ba032eb7c', 'bba38802-10d5-5192-920e-9e4869db49bb', '5f6ab7b5-c355-583f-b044-285ba65474ec', null, '🎯 Principle 7 standards', 'Principle 7: Case Presentation 


The Core of DSD Scorecard standards: 
"We are keen on observing our patients and Planning for treatment plan presentations, utilizing visuals from the DSD Planning Center, and ensuring effective communication of findings and proposed plans with patients."

Checklist:
☐ Our case presentations happen in our DSD Room and follow the DSD sequence (emotional, problems, solutions, and financial journeys).
☐ The presentation is well-planned by the DSD Coordinator and the doctor and uses visuals (from the DSD Planning Center slides) to explain to the patients the proposed treatments, always connecting them to the best photo of the mock-up.
☐ The DSD Coordinator or person responsible actively participates in explaining treatment decisions. They present financials right after the mock-up and treatment presentation, contributing to a high case acceptance rate.
☐ The team actively supports case presentations, engaging in meetings to review results, discuss enhancements, and plan actions for continuous improvement.', null, null, 'todo', 1000) on conflict (id) do nothing;
insert into public.tasks (id, campaign_id, parent_id, section_id, title, description, assignee_id, due_date, status, position) values ('8f1671e3-7b4d-59b0-857d-a08bbe9aeddf', 'bba38802-10d5-5192-920e-9e4869db49bb', '5f6ab7b5-c355-583f-b044-285ba65474ec', null, 'The Problems and Solutions Journey', 'Principle 7:  Case Presentation

After the Emotional Presentation, we continue guiding the patient through the rest of the case by clearly presenting the problems and the proposed solutions.

This part of the journey is equally important—because understanding the "why" behind the treatment plan builds trust, clarity, and confidence.

At DSD, we believe in using visual communication to support this step. When we show patients images, diagrams, and examples—instead of only using technical language—we make it easier for them to truly understand their diagnosis and options.

To help you, we’ve created a Problems & Solutions presentation template that you can adapt for your own use. Remember: every case is unique, so this template is a guide—not a fixed script. You’re encouraged to personalize it for each patient and adapt it to your clinic’s communication style.

You’ll also find:
    A presentation with examples of DSD cases to explain common treatment types to patients.
*We also recommend creating your own internal library of real cases from your clinic. Showing similar cases helps patients relate to the journey, visualize the outcomes, and feel more confident in your recommendations.

In this task, you’ll review these materials and reflect on how you currently present problems, solutions, and financials—and how to make this moment more clear, visual, and emotionally intelligent.

⭐ Content:
https://vimeo.com/801602353/5a41dc0b3e?share=copy

[image in the Asana original, not copied]


[Document] Mastering the Problems and Solutions Journey

https://docs.google.com/document/d/1uHp1_oFEioiarUgQ-1LJI9E1bCHJXJ9tbe_qcZobbfg/edit?usp=sharing
https://docs.google.com/document/d/1qsQOg-DRj0uhCMb7Kw_4EJfw_gyF7pqohTYd04h87Qo/edit?usp=sharing
https://docs.google.com/document/d/19uPEbqOJI7lTzhZldYKVD8DKxFaI7tAWbmV-6gr84RY/edit?usp=sharing
https://docs.google.com/document/d/1vfoozjRTp4C30AL4wLLxssBha19lwf6E1eQmKpy9xLI/edit?usp=sharing

https://3439767.fs1.hubspotusercontent-na1.net/hubfs/3439767/Clinical%20Cases%20DSD%20E%2BCF%2BTP%20template.key DOWNLOAD HERE (only English 🇬🇧)

[Document] Improving Case Presentation Effectiveness

https://docs.google.com/document/d/1YPSHHQKAgPDHPrmAxYobfXveQo3Tfpcxs6cWJ0HWGKY/edit?usp=sharing
https://docs.google.com/document/d/1dUwqVPU2UgzlFN7A8Z0fx61399AvnqdSTJy_0e-R_tE/edit?usp=sharing
https://docs.google.com/document/d/1yRac1T9HcSvCYL6Z53qb5HqeFI10WJ5x60ECiTqGVIM/edit?usp=sharing
https://docs.google.com/document/d/12alcNzYVATkNfi_RwWK81zwZrPYNFcOTEnDmzsAktI4/edit?usp=sharing


⭐ Content (Christian Coachman)
https://vimeo.com/966424248/2a44155608?share=copy

[image in the Asana original, not copied]


https://vimeo.com/966428193/a1e5380184?share=copy

[image in the Asana original, not copied]



🧠 Reflection:
    When presenting problems and solutions, are you helping the patient clearly understand their situation—or overwhelming them with clinical details?
    Think about how visuals, simple language, and relatable examples could improve your explanations.
    Do you currently use images or real cases from your own clinic to support your presentations?
    Reflect on how sharing similar cases could help build trust and make your recommendations more believable and inspiring.
    How comfortable and prepared do you feel when presenting the financial aspects of a case?
    Consider how emotional connection and clarity in the previous steps can make financial conversations easier and more positive for everyone.

📋 Action:
Complete the subtasks below:

Checklist:
☐ ⭐ Watch the [Tutorial] ''How to Use the Template to Build the Patient Presentation Creating a Story''
☐ ⭐ Read the [Document] ''Mastering the Problems and Solutions Journey''
☐ ⭐ Download the [Template] Examples of Clinical Cases
☐ ⭐ Read the [Document] Improving Case Presentation Effectiveness
☐ ⭐ Watch the [Videos] from Dr. Christian Coachman on Problems and Solutions Journey (2 videos)
☐ Using the template, create an Emotional + Problems + Solutions presentation tailored to a real patient, and upload it here.', null, null, 'todo', 2000) on conflict (id) do nothing;
insert into public.tasks (id, campaign_id, parent_id, section_id, title, description, assignee_id, due_date, status, position) values ('f7283c68-600b-5e8f-a4d0-1275336254c0', 'bba38802-10d5-5192-920e-9e4869db49bb', null, '98bf2aa5-6a56-5a4e-b3c2-094e6302b20c', 'Principle 8: DSD 2nd Appointment [Financial Journey. Case Acceptance + Follow Up + Tracking Numbers]', null, null, null, 'todo', 12000) on conflict (id) do nothing;
insert into public.tasks (id, campaign_id, parent_id, section_id, title, description, assignee_id, due_date, status, position) values ('d268fb9b-cac8-5648-9949-20dc11894e14', 'bba38802-10d5-5192-920e-9e4869db49bb', 'f7283c68-600b-5e8f-a4d0-1275336254c0', null, '🎯 Principle 8 standards', 'Principle 8: Case Acceptance + Follow Up + Tracking Numbers


The Core of DSD Scorecard standards: 
"Our patients embrace our services and place trust in our plan owing to our distinctive approach to patient experience and customer service. They''ve had the opportunity to envision their smiles and visually grasp the digitally planned treatment, enabling them to make well-informed decision."

Checklist:
☐ For DSD patients, our case acceptance rate ranges from 70% to 85%, marking a 15% increase since the implementation of DSD concepts. Additionally, the average ticket per case has surged by 30% due to patients'' enhanced appreciation and comprehension of our services.
☐ We meticulously monitor our case acceptance and average ticket figures, employing systematic follow-up procedures to engage patients who do not immediately accept the treatment plan after their second appointment.
☐ Seamless communication between the front office team and the DSD Coordinator ensures efficient post-presentation appointment scheduling, facilitating a smooth transition toward initiating treatment.', null, null, 'todo', 1000) on conflict (id) do nothing;
insert into public.tasks (id, campaign_id, parent_id, section_id, title, description, assignee_id, due_date, status, position) values ('2c511073-9e45-5961-a70c-6bbca6a19f65', 'bba38802-10d5-5192-920e-9e4869db49bb', 'f7283c68-600b-5e8f-a4d0-1275336254c0', null, 'Create your own Treatment Plan Template', 'Principle 8: Case Acceptance + Follow Up + Tracking Numbers

Create your Treatment Plan template

A well-designed Treatment Plan document is not just a summary of procedures and prices—it’s a communication tool that helps patients understand the value of what you’re offering, feel confident about their decisions, and move forward with clarity.


This template should be clear, visual, and personalized, allowing you to explain complex treatments in a way that is both professional and emotionally engaging.

In this task, you’ll get inspired by the examples below and start building your own version—one that fits your clinic’s workflow, tone, and patient profile.

The goal is to create a document that becomes a consistent part of your case acceptance process, supports follow-up conversations, and allows you to track case acceptance rates over time.

Let’s make your treatment proposals more than just numbers—let’s make them understandable, valuable, and convincing.


⭐ Content:
[Document] Personalized Smile Transformation Plan for a Patient

https://docs.google.com/document/d/1P2khhnX_QJKmgCZhs70JMKmETmuYRZZ9PO3kjFyav9Q/edit?usp=sharing
https://docs.google.com/document/d/1Ro9b67itH6DB3UQXZIK87FDbwC7xtSW0YAnvk8r8oNg/edit?usp=sharing
https://docs.google.com/document/d/14UbxUsu8jEmvFDw-_PNNJjcY6gt8wSZgg5HvbXBLyaw/edit?usp=sharing
https://docs.google.com/document/d/1FlZY66Lcd9zUa6LD3zIjuP3QHH6-t6UlikOAKoX80NI/edit?usp=sharing

https://media2-production.mightynetworks.com/asset/29691994/Detailed_Treatment_Plan.pdf?_gl=1*1577823*_ga*MTIyMTAxMjUwMi4xNjcxMDM5NzYz*_ga_T49FMYQ9FZ*MTcxNTY0NTI3NS4xODguMS4xNzE1NjQ4ODEwLjAuMC4w*_ga_NEGJ2SXNP7*MTcxNTY0NTI3Ni4xNTAuMS4xNzE1NjQ4ODA5LjYwLjAuMA.. (only English 🇬🇧)
https://media2-production.mightynetworks.com/asset/29837344/Ironwood_Invisalign_Estimate.pdf?_gl=1*18ml372*_ga*MTIyMTAxMjUwMi4xNjcxMDM5NzYz*_ga_T49FMYQ9FZ*MTcxNTY0NTI3NS4xODguMS4xNzE1NjQ4ODEwLjAuMC4w*_ga_NEGJ2SXNP7*MTcxNTY0NTI3Ni4xNTAuMS4xNzE1NjQ4ODA5LjYwLjAuMA.. (only English 🇬🇧)
https://media2-production.mightynetworks.com/asset/29837349/Ironwood_Dental_DSD_estimate_-_TEMPLATE.pdf?_gl=1*18ml372*_ga*MTIyMTAxMjUwMi4xNjcxMDM5NzYz*_ga_T49FMYQ9FZ*MTcxNTY0NTI3NS4xODguMS4xNzE1NjQ4ODEwLjAuMC4w*_ga_NEGJ2SXNP7*MTcxNTY0NTI3Ni4xNTAuMS4xNzE1NjQ4ODA5LjYwLjAuMA.. (only English 🇬🇧)

🧠 Reflection:
    When presenting treatment plans, do your patients truly understand the value behind what you’re offering—or are they just seeing a list of procedures and prices?
    Think about how you can use design, language, and structure to turn a technical document into a clear and motivating conversation.
    Is your current treatment plan format aligned with your clinic’s personality and patient profile?
    Reflect on tone, visuals, and layout. Would your patients describe it as professional, personalized, and easy to follow?

📋 Action:
Complete the subtasks below:

Checklist:
☐ ⭐ Read the [Document] ''Personalized Smile Transformation Plan for a Patient''
☐ ⭐ Read the [Examples] from other DSD Clinics
☐ ⭐ Create your own Treatment Plan Template following the suggestions and examples shared above.', null, null, 'todo', 2000) on conflict (id) do nothing;
insert into public.tasks (id, campaign_id, parent_id, section_id, title, description, assignee_id, due_date, status, position) values ('248cad24-c5ba-59d6-8d85-be745a91cfcb', 'bba38802-10d5-5192-920e-9e4869db49bb', 'f7283c68-600b-5e8f-a4d0-1275336254c0', null, 'Closing Techniques: Advanced Strategies to Improve Patient Case Acceptance', 'Principle 8: Case Acceptance + Follow Up + Tracking Numbers

Closing Techniques: Advanced Strategies to Improve Patient Case Acceptance


Why This Matters: A Strategic Resource for DSD Clinics.

This resource is designed for DSD Clinics that are ready to elevate their case acceptance strategy—moving beyond technical presentation into the emotional and psychological factors that truly drive patient decisions.

Many teams are already good at explaining treatment plans. But even with clear communication, they may still face hesitations, delays, or rejections from patients. That’s because case acceptance is not just about what we say—it’s about how patients feel, what they understand, and whether they trust us.

In this guide, you’ll explore:
    The emotional psychology behind decision-making
    How to create deeper connection through storytelling and mock-ups
    Ways to align your team’s language and tone for clarity and trust
    How to personalize follow-up strategies based on different patient profiles and cultures
    And how to integrate digital tools like AI and simulations to boost credibility and engagement

This is not a script. It’s a strategic, multidisciplinary approach that combines communication, leadership, and empathy—so that your patients feel empowered to say “yes” to the treatment that’s right for them.

In this task, you’ll review these advanced techniques, reflect on your current approach, and begin implementing small but powerful changes that can lead to more consistent results and long-term patient loyalty.

Let’s make every closing moment a confident, human, and impactful one.

⭐ Content:
[Document] Advanced Closing Techniques for Improving Patient Case Acceptance

https://docs.google.com/document/d/1nuF5jZkOP7zB7WDcaDMpx2FSVruelvVtuYDlFQqRq34/edit?usp=sharing
https://docs.google.com/document/d/1yESa0l4ZfSUtVoSfp3ZgAb6iPfw27nvd2ZOqZicbK4Q/edit?usp=sharing
https://docs.google.com/document/d/1upKty8DklZSL9NQAcLM-LHzmKzFzV47eZVxZHp8O-qM/edit?usp=sharing
https://docs.google.com/document/d/1rtjCBHAjPuoqgKAXZCXojVazBVuSHdaGZYtE8NwXVNQ/edit?usp=sharing

https://vimeo.com/817224699/62c1b78c01?share=copy

[image in the Asana original, not copied]



🧠 Reflection:
    When a patient says “I need to think about it,” what might really be behind that hesitation?
    Reflect on whether your current communication is addressing emotional concerns, building trust, and helping them truly understand the “why” behind the treatment.
    How aligned is your team when it comes to presenting and closing cases?
    Consider whether everyone—from doctors to coordinators—uses the same tone, storytelling style, and message clarity to support the decision-making process.
    What follow-up strategies do you currently use when a patient doesn’t say yes immediately?
    Think about whether your approach is reactive or proactive—and how it could be improved to feel more personalized, consistent, and culturally sensitive.

📋 Action:
Complete the subtasks below:

Checklist:
☐ ⭐ Read the [Document] ''Advanced Closing Techniques for Improving Patient Case Acceptance''
☐ ⭐ Watch the [Video] ''Closing Techniques for Improving Patient Case Acceptance with María Cabanellas''
☐ ⭐ Reflect as a Team: Define Your Closing Strategies, Objection Handling, and Patient-Specific Communication Protocols', null, null, 'todo', 3000) on conflict (id) do nothing;
insert into public.tasks (id, campaign_id, parent_id, section_id, title, description, assignee_id, due_date, status, position) values ('45c5f3eb-cc32-58ab-a4a6-adcf98d8dd59', 'bba38802-10d5-5192-920e-9e4869db49bb', 'f7283c68-600b-5e8f-a4d0-1275336254c0', null, 'Presenting Financials: a DSD Case', 'Principle 8: Case Acceptance + Follow Up + Tracking Numbers

Presenting Financials in a DSD Case

Creating clarity, trust, and consistency at one of the most critical moments.


Presenting the financials is not just a final step—it’s a key part of the patient experience that can reinforce trust, transparency, and confidence in your clinic.

In a DSD Clinic, we believe this moment deserves the same care and strategy as the clinical and emotional parts of the journey. The person delivering the financials should be fully informed about the patient’s DSD journey, emotionally connected to their story, and trained to create genuine rapport.

It’s not just about communicating a price—it’s about helping the patient understand the value of what they’re about to invest in.

In this task, you’ll reflect on how your team currently manages this part of the process, and explore ways to improve your systems, communication tone, and internal protocols, so that case closing becomes more efficient, personalized, and replicable—regardless of who is in charge.

Let’s make sure that presenting financials becomes a moment of clarity, trust, and alignment, not stress or confusion. 

⭐ Content:

[Document] Mastering Case Acceptance: Presenting Dental Treatment Financials with DSD

https://3439767.fs1.hubspotusercontent-na1.net/hubfs/3439767/Mastering_Case_Acceptance-_Presenting_Dental_Treatment_Financials_with_DSD_.pdf
https://3439767.fs1.hubspotusercontent-na1.net/hubfs/3439767/DEUTSCH.%20Case%20acceptance.pdf
https://3439767.fs1.hubspotusercontent-na1.net/hubfs/3439767/AGOSTO%20FINAL%20WORKBOOK%20DSD%20TEAM%20CONSULTANCY%20(SPANISH)%20(1).pdf
https://3439767.fs1.hubspotusercontent-na1.net/hubfs/3439767/ITALIANO%20MASTERING%20CASE%20ACCEPTANCE.pdf

🧠 Reflection:
    Who is currently presenting financials in your clinic—and are they truly connected to the DSD journey and the emotional context of each case?
    Reflect on whether the person delivering this information is equipped to create trust and communicate value, not just numbers.
    Is your current financial conversation structured and consistent—or does it vary depending on who’s presenting or how busy the day is?
    Think about how a defined protocol could help make this moment smoother and more professional every time.
    How do your patients typically feel during this part of the process—and what could you do to make them feel more confident, respected, and supported?
    Consider the tone, setting, language, and timing. Sometimes, small adjustments can completely change how the conversation is perceived.

📋 Action:
Complete the subtasks below:

Checklist:
☐ ⭐ Read [Document] ''Mastering Case Acceptance: Presenting Dental Treatment Financials with DSD''
☐ Share a real example of how you currently present financials to your patients. What format do you use—email, printed document, folder, or another method? Upload it here.', null, null, 'todo', 4000) on conflict (id) do nothing;
insert into public.tasks (id, campaign_id, parent_id, section_id, title, description, assignee_id, due_date, status, position) values ('2ec37268-65a7-5b34-a270-f0c6be5bfd39', 'bba38802-10d5-5192-920e-9e4869db49bb', 'f7283c68-600b-5e8f-a4d0-1275336254c0', null, 'Follow-Up With Your Patients', 'Principle 8: Case Acceptance + Follow Up + Tracking Numbers

Follow-Up With Your Patients.

Consistency, care, and structure—beyond the consultation.

How we follow up with patients—whether they have accepted the treatment plan or not—is a key part of the DSD experience. It’s not just about reminding or chasing decisions; it’s about showing professionalism, empathy, and commitment to helping them move forward at their own pace.

At DSD Clinics, follow-up should be guided by clear protocols and systems defined as a team. We should use standardized templates for emails, messages, calls, and texts that allow us to communicate in a way that is both personal and consistent.

Whenever possible, we should automate the process to reduce the risk of human error and ensure that no patient is forgotten or left without the right level of support.

In this task, you’ll review your current follow-up system and reflect on how well it aligns with the DSD standards for clarity, warmth, and structure. You’ll also explore ways to improve automation, delegate responsibilities, and keep track of follow-up conversations over time.
Let’s turn follow-up into a powerful moment of connection, not an afterthought.

⭐ Content:
[Document] DSD Clinics. Patient Follow-Up Templates 

https://docs.google.com/document/d/17yS7-uDepBK6jN89rMdbcS1g1c6oyqpp6WwisKrbx0M/edit?usp=sharing
https://docs.google.com/document/d/1Rh4_Rjy7D4lZZI1_S4aBewMi35xmzJDfqCzV3d-VkNA/edit?usp=sharing
https://docs.google.com/document/d/18MNrEHoQnx6Qa5SNPF1ps1dr28P7JjOKMrc1jaaGSuA/edit?usp=sharing
https://docs.google.com/document/d/1tZp6nHnlev4KxkwecHfhk1vmgK5D01MuvpuAtBGuhPE/edit?usp=sharing

In this document you will find examples and templates for emails, sms and telephone conversations for all phases of the DSD Patient Journey:
1. Before the first visit: Templates for emails, SMS and phone conversations.
2. Between the first and second visit: Templates for emails, SMS and phone conversations.
3. After the second visit: Templates for e-mails, SMS and telephone conversations.
4. Examples of patient objections: Common patient objections after the second visit and suggested responses.
5. ChatGPT prompts: The exact text we used to create these templates, so that you can adapt or create your own materials.


🧠 Reflection:
    Do you have a clear and consistent follow-up protocol for both accepted and non-accepted cases?
    Think about whether everyone on your team knows what to do, when to do it, and how to communicate in a way that reflects your clinic’s values.
    Are your follow-up messages creating connection—or do they feel generic or transactional?
    Reflect on how you could make your communication more human, caring, and relevant to each patient’s situation.
    How are you currently tracking follow-up conversations and ensuring nothing falls through the cracks?
    Consider what systems, tools, or automations could help you stay organized and make your process more reliable and scalable.

📋 Action:
Complete the subtasks below:

Checklist:
☐ ⭐ Read the [Document] ‘DSD Clinics. Patient follow-up templates''
☐ ⭐ Using the document above and AI, create your own personalized templates for emails, SMS, and patient conversations. Use the suggestions, examples, and prompts provided to guide your writing and adapt them to your clinic’s tone and needs. Upload them here.
☐ ⭐ Do you have a follow-up protocol for your current patients? Describe your current system, tools, or routine for staying in touch after presenting the treatment plan.
☐ ⭐ Do you use templates? Share or create your templates', null, null, 'todo', 5000) on conflict (id) do nothing;
insert into public.tasks (id, campaign_id, parent_id, section_id, title, description, assignee_id, due_date, status, position) values ('406efdeb-7780-52ea-8bc9-7a0af11086db', 'bba38802-10d5-5192-920e-9e4869db49bb', 'f7283c68-600b-5e8f-a4d0-1275336254c0', null, 'Tracking Numbers', 'Principle 8: Case Acceptance + Follow Up + Tracking Numbers



Tracking Numbers

Because what gets measured, gets improved.

Having a clear and consistent system for tracking your numbers is essential to understanding how your clinic is growing—not just in general, but in specific, strategic areas like case acceptance, treatment types, doctor performance, and patient behavior over time.

At DSD Clinics, we should track data with precision and purpose. This allows us to identify trends, celebrate progress, and detect areas for improvement across months, years, services, and team members.

For example:

> “Since implementing DSD concepts, our case acceptance rate for DSD patients has increased by 15%, now ranging from 70% to 85%. The average case value has also grown by 30%, thanks to patients better understanding and valuing the treatment journey.”


In this task, you’ll review the key metrics your team is currently tracking (or not yet tracking), and define how to measure the real impact of your DSD workflows.

It’s not just about having the numbers—it’s about using them to drive smarter decisions, stronger communication, and meaningful growth.

Let’s build a system that gives you clarity, celebrates your progress, and supports your future strategy.

⭐ Content:
https://vimeo.com/1097829352/927437b680?share=copy

[image in the Asana original, not copied]


[Document] ''Tracking Numbers in a Dental Practice''

https://docs.google.com/document/d/1_aoiDMwac6TniYfKxuv7aeE7vbDAi0w7vpnl3oWCzL4/edit?usp=sharing
https://docs.google.com/document/d/1y4I-7QtCNiZp64fN6vw-zGKWJqH_sej6BKOk4z4GQj8/edit?usp=sharing
https://docs.google.com/document/d/1IHHp33UJ-_7OfrKzvhLiMJiwzXYbZi3lI7isnTsSYUA/edit?usp=sharing
https://docs.google.com/document/d/1JHBRFNNcIFtrAj77JJBhi1OXDXTlpMqpJc6ZnjWphH0/edit?usp=sharing

[Template] ‘KPI Tracking Template’ (Google Sheet)

https://docs.google.com/spreadsheets/d/1TdJidb_ndvP8FYbNodg7VvdI2UgnoQ9tB_Z_d3QCIhc/copy?gid=1870464681#gid=1870464681
https://docs.google.com/spreadsheets/d/1qGU_1JS0PZcioJfPeJQHb08F6uNoQiiV6Kk5w7iK85I/copy
https://docs.google.com/spreadsheets/d/1v2UAjNSjcK11hEgausQSCsVyjUeJISvDhuNRkQHLEA0/copy
https://docs.google.com/spreadsheets/d/1gvksU3Cfmo5PowJcdZEuzPqQfaovXCVfUZDAtdcxbNk/copy

🧠 Reflection:
    What are the key numbers your team is currently tracking—and do they truly reflect the impact of your DSD work?
    Do you review your numbers regularly as a team—or do they sit in a system without guiding your decisions?
    Reflect on how often and how meaningfully you use your data to evaluate progress and shape strategy.
    Is your team emotionally connected to the numbers—or do they feel like distant admin tasks?
    Consider how you can make metrics part of your culture: something that inspires ownership, accountability, and celebration.

📋 Action:
Complete the subtasks below:

Checklist:
☐ ⭐ Watch the [Video] ''The Power Of Tracking Numbers In Your Dental Practice''
☐ ⭐ Read the [Document] ''Tracking Numbers in a Dental Practice''
☐ ⭐ Check the [Template] ‘KPI Tracking Template’
☐ ⭐ What numbers are you tracking at the moment?
☐ ⭐ What''s your Case Acceptance rate with and without DSD?
☐ ⭐ What''s your Average Ticket per patient with and without DSD?
☐ ⭐ Any other numbers that you track?
☐ ⭐ Protocol: How often does your team review performance numbers? Describe your current routine for analyzing results, identifying what’s working, and discussing areas for improvement.', null, null, 'todo', 6000) on conflict (id) do nothing;
insert into public.tasks (id, campaign_id, parent_id, section_id, title, description, assignee_id, due_date, status, position) values ('21877491-cf15-5287-94f1-86e16a9fee0b', 'bba38802-10d5-5192-920e-9e4869db49bb', 'f7283c68-600b-5e8f-a4d0-1275336254c0', null, 'DSD 2nd Appointment scripts. Financial Journey', 'DSD 2nd Appointment Scripts. Financial Journey 

A guide designed to support your team during financial conversations with patients. 

It includes examples of how to approach different situations—such as patients who are shocked by the cost, highly analytical, emotionally connected but financially limited, or asking for discounts. 
It helps you lead financial discussions with clarity, empathy, and assertiveness while maintaining a professional and positive tone.

[Document] DSD 2nd Appointment scripts. Financial Journey

https://docs.google.com/document/d/10lHwF7aRfApdnDJ8Q5nC_NrsH5kbzIrjAhoHeraR5ME/edit?usp=sharing
https://docs.google.com/document/d/1buemBKF9JmGa71oukyDRPyA176H3ipcPYzSGvF7AcL8/edit?usp=sharing
https://docs.google.com/document/d/1a2vDL-6RT15ZozviOELwGsxQ96mOScnsLQIbhMIzy6Y/edit?usp=sharing
https://docs.google.com/document/d/1SWfS1Py02qqk1GzPyunttLrgiZ5UuE7wur2JfSOB5Og/edit?usp=sharing


📋 Action:
Complete the subtasks below:

Checklist:
☐ ⭐ Read the [Document] ''Scripts''. Use it as a team to get inspired, gather communication resources and ideas, or even practice role plays together to handle objections, challenging conversations, and tricky questions or answers', null, null, 'todo', 7000) on conflict (id) do nothing;

-- Monthly Payments & Invoice Control
insert into public.campaigns (id, name, description, department_id, for_department_id, status, start_date, end_date, owner_id, planned_hours, private, is_template)
values ('f1ddb8c1-6b93-5579-8442-715bc9ae9870', 'Monthly Payments & Invoice Control', 'Procurement''s monthly invoice and payment control. Name each month''s project like “2027-01 Payments & Invoice Control”. Add one task per invoice in the week it is paid, and fill in the invoice fields.', public.department_id_for('corporate'), public.department_id_for('corporate'), 'planned', '2026-01-01', '2026-01-31', (select id from public.people where lower(email) like 'csolla@%' limit 1), 0, false, true)
on conflict (id) do nothing;
insert into public.sections (id, campaign_id, name, position) values ('eeffd890-aec7-56e8-b681-d8885636bd50', 'f1ddb8c1-6b93-5579-8442-715bc9ae9870', 'Scheduled payments – Week 1', 1000) on conflict (id) do nothing;
insert into public.sections (id, campaign_id, name, position) values ('dbbb3c91-31bd-5148-8781-e35b40bf9b1d', 'f1ddb8c1-6b93-5579-8442-715bc9ae9870', 'Scheduled payments – Week 2', 2000) on conflict (id) do nothing;
insert into public.sections (id, campaign_id, name, position) values ('b1b62869-40fe-548c-a6e3-1423a98f729e', 'f1ddb8c1-6b93-5579-8442-715bc9ae9870', 'Scheduled payments – Week 3', 3000) on conflict (id) do nothing;
insert into public.sections (id, campaign_id, name, position) values ('b30ced1f-1f72-5544-9d4e-bb84fcd00c6a', 'f1ddb8c1-6b93-5579-8442-715bc9ae9870', 'Scheduled payments – Week 4', 4000) on conflict (id) do nothing;
insert into public.sections (id, campaign_id, name, position) values ('94f9bd2b-99f1-514b-94fa-f8f7efccda59', 'f1ddb8c1-6b93-5579-8442-715bc9ae9870', 'Scheduled payments – Week 5', 5000) on conflict (id) do nothing;
insert into public.sections (id, campaign_id, name, position) values ('9aa05638-ce09-54d6-9f67-c3f58b02cbf9', 'f1ddb8c1-6b93-5579-8442-715bc9ae9870', 'Direct debits – Week 1', 6000) on conflict (id) do nothing;
insert into public.sections (id, campaign_id, name, position) values ('0e020756-7a64-5e6d-adc7-1e685004bc3b', 'f1ddb8c1-6b93-5579-8442-715bc9ae9870', 'Direct debits – Week 2', 7000) on conflict (id) do nothing;
insert into public.sections (id, campaign_id, name, position) values ('84bb5cf7-cc18-521d-a912-accab87917f9', 'f1ddb8c1-6b93-5579-8442-715bc9ae9870', 'Direct debits – Week 3', 8000) on conflict (id) do nothing;
insert into public.sections (id, campaign_id, name, position) values ('b2f065bd-b6b2-54cf-b574-fa9db82a2712', 'f1ddb8c1-6b93-5579-8442-715bc9ae9870', 'Direct debits – Week 4', 9000) on conflict (id) do nothing;
insert into public.sections (id, campaign_id, name, position) values ('e17ca2ba-a002-58ba-ad5f-36b12c707fe5', 'f1ddb8c1-6b93-5579-8442-715bc9ae9870', 'Direct debits – Week 5', 10000) on conflict (id) do nothing;
insert into public.sections (id, campaign_id, name, position) values ('ee832d0d-8c46-5829-9d25-6c9ef8600816', 'f1ddb8c1-6b93-5579-8442-715bc9ae9870', 'Bankinter cards', 11000) on conflict (id) do nothing;
insert into public.sections (id, campaign_id, name, position) values ('1d145d35-0324-51d7-a501-f3d9bc89c4fe', 'f1ddb8c1-6b93-5579-8442-715bc9ae9870', 'Paid', 12000) on conflict (id) do nothing;
insert into public.custom_fields (id, campaign_id, name, type, settings, position) values ('1e837cb5-5669-53f1-a3a1-987712dafe12', 'f1ddb8c1-6b93-5579-8442-715bc9ae9870', 'Invoice date', 'date', '{}'::jsonb, 1000) on conflict (id) do nothing;
insert into public.custom_fields (id, campaign_id, name, type, settings, position) values ('6ac8a915-5cbb-558b-a010-9577e7d54ec7', 'f1ddb8c1-6b93-5579-8442-715bc9ae9870', 'Invoice nº', 'text', '{}'::jsonb, 2000) on conflict (id) do nothing;
insert into public.custom_fields (id, campaign_id, name, type, settings, position) values ('e5653a6c-ae05-5489-88e2-975424e7b7ad', 'f1ddb8c1-6b93-5579-8442-715bc9ae9870', 'Payment method', 'choice', '{"options": ["Wire transfer", "Direct Debit", "Pleo", "Bankinter -5371", "Balance", "Renting", "Cash"]}'::jsonb, 3000) on conflict (id) do nothing;
insert into public.custom_fields (id, campaign_id, name, type, settings, position) values ('201b5dca-b57d-5719-8dc0-702591b5c272', 'f1ddb8c1-6b93-5579-8442-715bc9ae9870', 'Invoice', 'choice', '{"options": ["Available", "Non Available"]}'::jsonb, 4000) on conflict (id) do nothing;
insert into public.custom_fields (id, campaign_id, name, type, settings, position) values ('21c65824-2ae8-5f97-9fb0-02fef870fd1b', 'f1ddb8c1-6b93-5579-8442-715bc9ae9870', 'Finance payment', 'choice', '{"options": ["Pending", "Uploaded", "Done", "Info required"]}'::jsonb, 5000) on conflict (id) do nothing;
insert into public.custom_fields (id, campaign_id, name, type, settings, position) values ('682d7992-8357-5e82-8bd4-f3010eb1c9cc', 'f1ddb8c1-6b93-5579-8442-715bc9ae9870', 'Signed', 'choice', '{"options": ["Yes", "No"]}'::jsonb, 6000) on conflict (id) do nothing;
insert into public.custom_fields (id, campaign_id, name, type, settings, position) values ('68fdacaa-d9b4-572f-b8f3-85f32c040cbb', 'f1ddb8c1-6b93-5579-8442-715bc9ae9870', 'Payment due', 'date', '{}'::jsonb, 7000) on conflict (id) do nothing;
insert into public.custom_fields (id, campaign_id, name, type, settings, position) values ('0341d16b-c7d4-5309-942b-8d5bb0f12498', 'f1ddb8c1-6b93-5579-8442-715bc9ae9870', 'P&L account', 'multi', '{"options": ["201.1 - COGS Growth", "1.Clinics*", "1.3 Planning Center", "1.3.1-Planning", "1.3.2-Lab", "Balance", "104-Other Income", "201.2 - COGS Delight", "06-Labour", "201.3 - COGS Planning Center", "07-Travels and Meals", "201.4 - COGS Lab", "201.5 - COGS Other Income", "Labour", "08-Professional Fees", "09-Marketing and Advertising", "202.1 - Labour Growth", "202.2 - Labour Marketing", "10-Office", "11-Information Technology", "202.3 - Labour Planning Center", "12-Research and Development*", "202.4 - Labour Corporate", "202.5 - Labour Delight ROW", "14-Miscellanous", "202.6 - Labour AMEX", "203.1 - Travels & Meals Growth", "203.2 - Travels & Meals Marketing", "203.3 - Travels & Meals Planning Center", "204.4 - Travels & Meals Lab", "203.5 Travels & Meals Corporate", "203.6 - Travels & Meals ROW", "203.7 - Travels & Meals AMEX", "204.1 - Professional Fees Spain", "204.2 - Professional Fees USA", "205.0 - Marketing & Advertising", "206.1 - Office Spain", "206.2 - Office USA", "207.0 - Information Technology", "208.0 - Research and Develpment", "209.1 - Bank and Financial fees SPAIN", "209.2 - Bank and Financial Fees USA", "0000 - Balance Adjustments", "210.0 Miscellanous", "Financing"]}'::jsonb, 8000) on conflict (id) do nothing;
insert into public.custom_fields (id, campaign_id, name, type, settings, position) values ('c3775245-1e91-5f4e-a015-ecc98e05befa', 'f1ddb8c1-6b93-5579-8442-715bc9ae9870', 'Departmental big line', 'choice', '{"options": ["100 - COGS", "200 - Labour", "300 - General Expenses", "400 - Dedicated Expenses"]}'::jsonb, 9000) on conflict (id) do nothing;
insert into public.custom_fields (id, campaign_id, name, type, settings, position) values ('e023ce93-4d1c-5c0a-80b7-9afbaf406553', 'f1ddb8c1-6b93-5579-8442-715bc9ae9870', 'Department', 'choice', '{"options": ["1.0.0 - Education", "2.0.0 - Lab", "3.0.0 - Corporate"]}'::jsonb, 10000) on conflict (id) do nothing;
insert into public.custom_fields (id, campaign_id, name, type, settings, position) values ('4f755d95-28dc-5b5c-b247-26e2bce32e66', 'f1ddb8c1-6b93-5579-8442-715bc9ae9870', 'Sub-department', 'choice', '{"options": ["1.1.0 - Education", "2.1.0 - Lab", "2.1.1 - PC", "2.1.2 - Delight", "3.1.0 - Corporate", "3.1.2 - Marketing"]}'::jsonb, 11000) on conflict (id) do nothing;
insert into public.custom_fields (id, campaign_id, name, type, settings, position) values ('8232d6b2-7158-5f80-ac34-9a5f9521e3e1', 'f1ddb8c1-6b93-5579-8442-715bc9ae9870', 'Total amount', 'money', '{"currencies": ["€", "US$", "GBP", "AUD$", "CAD$", "R$", "ZAR", "RAND", "BRL"]}'::jsonb, 500) on conflict (id) do nothing;

-- DSD Clinics Onboarding
insert into public.campaigns (id, name, description, department_id, for_department_id, status, start_date, end_date, owner_id, planned_hours, private, is_template)
values ('4149a72e-28f1-5e61-bb94-9336f70724a4', 'DSD Clinics Onboarding', 'Onboarding of a new DSD Clinic, from pre-onboarding and activation to graduation. Name the project “DSD Clinics Onboarding - [Clinic or doctor] ([Month Year])”. The “Person responsible / department” field says who does each task.', public.department_id_for('delight'), public.department_id_for('delight'), 'planned', '2026-01-05', '2026-04-05', (select id from public.people where lower(email) like 'csolla@%' limit 1), 0, false, true)
on conflict (id) do nothing;
insert into public.sections (id, campaign_id, name, position) values ('2129df38-49f8-58f0-a85e-ca9ab15a22a5', '4149a72e-28f1-5e61-bb94-9336f70724a4', 'Pre-Onboarding & Activation', 1000) on conflict (id) do nothing;
insert into public.sections (id, campaign_id, name, position) values ('adff592b-eb38-52cd-bbcb-441926316e30', '4149a72e-28f1-5e61-bb94-9336f70724a4', 'Post Onboarding', 2000) on conflict (id) do nothing;
insert into public.sections (id, campaign_id, name, position) values ('1d630e36-0957-522f-8697-c13daf594ba8', '4149a72e-28f1-5e61-bb94-9336f70724a4', 'DSD Consultancy workflow activation', 3000) on conflict (id) do nothing;
insert into public.sections (id, campaign_id, name, position) values ('8b0ce268-84e7-5e33-a9f6-327344f90e50', '4149a72e-28f1-5e61-bb94-9336f70724a4', 'DSD Clinic DURING Coaching', 4000) on conflict (id) do nothing;
insert into public.sections (id, campaign_id, name, position) values ('29dd0337-6f69-529a-b36b-65556e673840', '4149a72e-28f1-5e61-bb94-9336f70724a4', 'DSD Clinic AFTER Coaching - Graduation', 5000) on conflict (id) do nothing;
insert into public.custom_fields (id, campaign_id, name, type, settings, position) values ('aaf062b3-3933-516e-8e11-3b4b88e1fea9', '4149a72e-28f1-5e61-bb94-9336f70724a4', 'Person responsible / department', 'text', '{}'::jsonb, 1000) on conflict (id) do nothing;
insert into public.tasks (id, campaign_id, parent_id, section_id, title, description, assignee_id, due_date, status, position) values ('bae193d2-a5e4-543d-b4c4-91cca1366091', '4149a72e-28f1-5e61-bb94-9336f70724a4', null, '2129df38-49f8-58f0-a85e-ca9ab15a22a5', 'Designate Account Manager', 'AMEX: Michelle Carpio or Elisa Bedin
ROW: JJ', null, null, 'todo', 1000) on conflict (id) do nothing;
insert into public.task_field_values (task_id, field_id, campaign_id, value) values ('bae193d2-a5e4-543d-b4c4-91cca1366091', 'aaf062b3-3933-516e-8e11-3b4b88e1fea9', '4149a72e-28f1-5e61-bb94-9336f70724a4', '"JJ"'::jsonb) on conflict (task_id, field_id) do nothing;
insert into public.tasks (id, campaign_id, parent_id, section_id, title, description, assignee_id, due_date, status, position) values ('3a7eb45e-2d03-5b38-9be5-27e3829e463f', '4149a72e-28f1-5e61-bb94-9336f70724a4', null, '2129df38-49f8-58f0-a85e-ca9ab15a22a5', 'Sign the DSD Clinic contract before the client is activated', 'https://app.pandadoc.com/a/#/documents-next?sortBy=date_modified&direction=desc&displayMode=folders_first&customDate=date_modified&mainFilter=all', null, null, 'todo', 2000) on conflict (id) do nothing;
insert into public.task_field_values (task_id, field_id, campaign_id, value) values ('3a7eb45e-2d03-5b38-9be5-27e3829e463f', 'aaf062b3-3933-516e-8e11-3b4b88e1fea9', '4149a72e-28f1-5e61-bb94-9336f70724a4', '"Account Manager"'::jsonb) on conflict (task_id, field_id) do nothing;
insert into public.tasks (id, campaign_id, parent_id, section_id, title, description, assignee_id, due_date, status, position) values ('74506005-1d53-5d8f-ac94-6152cd73b2ca', '4149a72e-28f1-5e61-bb94-9336f70724a4', null, '2129df38-49f8-58f0-a85e-ca9ab15a22a5', 'Send Welcome email with Payment Forms and Scheduling Link to Client', 'DSD Clinics Email 0 Welcome and Next Steps Pre-Onboarding
Subject line:
Welcome to the DSD Clinic Community!
Preview text:


Dear Clinic Team,
 
Congratulations and welcome to the DSD Clinic community. You are joining a global network of practices committed to delivering exceptional patient experiences through the Digital Smile Design methodology. Becoming a DSD Clinic is an important milestone, and we look forward to partnering with you throughout your journey.

My name is [Account Manager''s name], and I''ll be your dedicated Account Manager. I''ll be your primary point of contact for all non-clinical aspects of your membership and will help ensure you get the most value from your DSD Clinic experience.
 
What happens next
Before we begin your activation, there are two important steps to complete:

1) Complete your payment authorization forms: To begin your activation, we need both forms completed and on file. Please complete both the ACH Authorization Form and the Credit Card Authorization Form, and reply to let me know which method you''d like to designate as primary and which as secondary backup.

2) Schedule your onboarding call: Once your payment forms are submitted, please schedule our 60-minute onboarding call using this link.
 
During our onboarding call, we will cover:
    Your DSD Clinic benefits
    Platform access
    Concierge services
    Membership resources
    What to expect throughout your DSD journey
    Your next steps following activation
 
Following our onboarding meeting, we will finalize your activation and introduce you to your dedicated DSD Coach. If you have any questions before then, please don''t hesitate to reach out.
 
Warm regards,

Your Name
DSD Account Manager

✉️ email@digitalsmiledesign.com
📞 Phone number



----------------------------------------



Document with two welcome emails: https://docs.google.com/document/d/1uYhVIls4V7MRQlsqt4-vl2NrjxV1-9wsmtpGJXQRRRc/edit?tab=t.0

The email template for this task is called ''DSD Clinics Email 0 Welcome and Next Steps Pre-Onboarding''


----------------------------------------



Instructions for how to use the templates:


Hubspot seems to be a bit funny with the links to templates, they seem to work for a bit and then not. The easiest way is to:

    Click ''create email'' 
    Select the template you need from the screen when it asks you to choose. These are the names to look for. They should be at the top if you filter by recently updated. 

DSD Clinics Email 0 Welcome and Next Steps Pre-Onboarding

DSD Clinics Email 1 Welcome to the Next Phase Post-Onboarding and Activation

DSD Clinics Welcome Email after GRADUATION

Then, your email will be pre-populated with the correct text and you can edit every part of it, add subject line and preview text, change the sender name, update links, etc. 

Here''s a loom on how to use the template/edit the email you''ve created: https://www.loom.com/share/20c43cbd5b5a448d9a14b0091a6c92f8

The subscription type is:
Requested resources and customer updates

For the email name, an example would be:
202609-07 | CUST | EML | Dental Unit | Email 0 Welcome and Next Steps Pre-Onboarding', null, null, 'todo', 3000) on conflict (id) do nothing;
insert into public.task_field_values (task_id, field_id, campaign_id, value) values ('74506005-1d53-5d8f-ac94-6152cd73b2ca', 'aaf062b3-3933-516e-8e11-3b4b88e1fea9', '4149a72e-28f1-5e61-bb94-9336f70724a4', '"Account Manager"'::jsonb) on conflict (task_id, field_id) do nothing;
insert into public.tasks (id, campaign_id, parent_id, section_id, title, description, assignee_id, due_date, status, position) values ('f874c205-b194-5f7b-b2f6-dfe8e3c95ab9', '4149a72e-28f1-5e61-bb94-9336f70724a4', null, '2129df38-49f8-58f0-a85e-ca9ab15a22a5', 'Follow up to ensure onboarding has been scheduled', null, null, null, 'todo', 4000) on conflict (id) do nothing;
insert into public.task_field_values (task_id, field_id, campaign_id, value) values ('f874c205-b194-5f7b-b2f6-dfe8e3c95ab9', 'aaf062b3-3933-516e-8e11-3b4b88e1fea9', '4149a72e-28f1-5e61-bb94-9336f70724a4', '"Account Manager"'::jsonb) on conflict (task_id, field_id) do nothing;
insert into public.tasks (id, campaign_id, parent_id, section_id, title, description, assignee_id, due_date, status, position) values ('b85c690f-c254-5e22-97d8-8bfb728d13ae', '4149a72e-28f1-5e61-bb94-9336f70724a4', 'f874c205-b194-5f7b-b2f6-dfe8e3c95ab9', null, 'Create Gamma On-boarding deck', 'https://gamma.app/docs/Onboarding-Deck-2025-nhxmfuzj4dfpfhc', null, null, 'todo', 1000) on conflict (id) do nothing;
insert into public.tasks (id, campaign_id, parent_id, section_id, title, description, assignee_id, due_date, status, position) values ('510ec559-96a0-52f1-ae94-addd23b70451', '4149a72e-28f1-5e61-bb94-9336f70724a4', 'f874c205-b194-5f7b-b2f6-dfe8e3c95ab9', null, 'Send credit card / ACH / GoCardless form to Finance', 'Send to Valeria (vevangelista@digitalsmiledesign.com), with JJ (jj@digitalsmiledesign.com) and Fernando (fernando@digitalsmiledesign.com) on CC.

Be sure to include the contract type, special conditions, and billing start date on the email.', null, null, 'todo', 2000) on conflict (id) do nothing;
insert into public.tasks (id, campaign_id, parent_id, section_id, title, description, assignee_id, due_date, status, position) values ('83223240-df62-5178-a3e4-d60e0908c7b0', '4149a72e-28f1-5e61-bb94-9336f70724a4', null, '2129df38-49f8-58f0-a85e-ca9ab15a22a5', 'Approved - To Be Activated -> Activated As Clinic', 'DSD Clinic Audit : Client Approval: https://app.asana.com/0/1201685490396059/list', null, null, 'todo', 5000) on conflict (id) do nothing;
insert into public.task_field_values (task_id, field_id, campaign_id, value) values ('83223240-df62-5178-a3e4-d60e0908c7b0', 'aaf062b3-3933-516e-8e11-3b4b88e1fea9', '4149a72e-28f1-5e61-bb94-9336f70724a4', '"Account Manager"'::jsonb) on conflict (task_id, field_id) do nothing;
insert into public.tasks (id, campaign_id, parent_id, section_id, title, description, assignee_id, due_date, status, position) values ('f6911dbc-ce65-506c-8a83-96c7d1176315', '4149a72e-28f1-5e61-bb94-9336f70724a4', '83223240-df62-5178-a3e4-d60e0908c7b0', null, 'Change Activation Status on "DSD Clinic - Client Approval" Asana Project', 'Asana Project - https://app.asana.com/1/472634702533497/project/1201685490396059/list/1205115857651727

Option A - consultancy Included
Option C - Consultancy Not Included', null, null, 'todo', 1000) on conflict (id) do nothing;
insert into public.tasks (id, campaign_id, parent_id, section_id, title, description, assignee_id, due_date, status, position) values ('5a8df79f-8aa7-579b-a350-fe73f0c22d1e', '4149a72e-28f1-5e61-bb94-9336f70724a4', null, '2129df38-49f8-58f0-a85e-ca9ab15a22a5', 'Activate Benefits and Offline Payment Method', 'Login into the admin view on Craft, go to Users. Find through the email address the user of the DSD Clinic. Click on "Permissions", and tick:

    DSD clinic box
    Coins Bronze (only if account is not already in any other Tier)
    UNTICK the box called DSD Master (this will avoid double discounts)
    Respective User Group for unlimited design, if applicable
    MRR DSD Clinics box
    On any designs included in contract (i.e. U-UL-SD)', null, null, 'todo', 6000) on conflict (id) do nothing;
insert into public.task_field_values (task_id, field_id, campaign_id, value) values ('5a8df79f-8aa7-579b-a350-fe73f0c22d1e', 'aaf062b3-3933-516e-8e11-3b4b88e1fea9', '4149a72e-28f1-5e61-bb94-9336f70724a4', '"Account Manager"'::jsonb) on conflict (task_id, field_id) do nothing;
insert into public.tasks (id, campaign_id, parent_id, section_id, title, description, assignee_id, due_date, status, position) values ('f77736de-ac6b-5a6d-8061-8d50b4d71a03', '4149a72e-28f1-5e61-bb94-9336f70724a4', null, '2129df38-49f8-58f0-a85e-ca9ab15a22a5', 'Fill out HubSpot DSD Clinic information', '    Make sure DSD Clinic company is created
    Make sure appropriate Dr is linked to company, other associates, etc.
    Fill out DSD Clinic properties on left sidebar
    Under doctor''s contact profile in HS, change status to Yes under DSD Clinic on left hand side
    Ensure all associates HS contact profiles are updated as well, to a Yes under DSD Clinic.', null, null, 'todo', 7000) on conflict (id) do nothing;
insert into public.task_field_values (task_id, field_id, campaign_id, value) values ('f77736de-ac6b-5a6d-8061-8d50b4d71a03', 'aaf062b3-3933-516e-8e11-3b4b88e1fea9', '4149a72e-28f1-5e61-bb94-9336f70724a4', '"Account Manager"'::jsonb) on conflict (task_id, field_id) do nothing;
insert into public.tasks (id, campaign_id, parent_id, section_id, title, description, assignee_id, due_date, status, position) values ('54fd8888-a869-5374-b56a-97d0e22333e8', '4149a72e-28f1-5e61-bb94-9336f70724a4', null, '2129df38-49f8-58f0-a85e-ca9ab15a22a5', 'Confirm Consultancies has been completed and, if it hasn''t happened yet, inform the client about its importance during the on-boarding call and follow-ups', null, null, null, 'todo', 8000) on conflict (id) do nothing;
insert into public.task_field_values (task_id, field_id, campaign_id, value) values ('54fd8888-a869-5374-b56a-97d0e22333e8', 'aaf062b3-3933-516e-8e11-3b4b88e1fea9', '4149a72e-28f1-5e61-bb94-9336f70724a4', '"Account Manager"'::jsonb) on conflict (task_id, field_id) do nothing;
insert into public.tasks (id, campaign_id, parent_id, section_id, title, description, assignee_id, due_date, status, position) values ('1abd3211-7d95-5e55-b85b-74b25e23d34a', '4149a72e-28f1-5e61-bb94-9336f70724a4', null, '2129df38-49f8-58f0-a85e-ca9ab15a22a5', 'Add to the DSD Clinics Database. See description', 'Fill out the corresponding information for each clinic in the following spreadsheet. This spreadsheet is the main guideline for DSD Clinic information, so it is important that it is accurate and constantly updated. 
https://docs.google.com/spreadsheets/d/1aOPI08X8NqgZQFFTe00XoPtuCmG62lnOqU0FVREDO0g/edit?gid=1349487200#gid=1349487200', null, null, 'todo', 9000) on conflict (id) do nothing;
insert into public.task_field_values (task_id, field_id, campaign_id, value) values ('1abd3211-7d95-5e55-b85b-74b25e23d34a', 'aaf062b3-3933-516e-8e11-3b4b88e1fea9', '4149a72e-28f1-5e61-bb94-9336f70724a4', '"Account Manager"'::jsonb) on conflict (task_id, field_id) do nothing;
insert into public.tasks (id, campaign_id, parent_id, section_id, title, description, assignee_id, due_date, status, position) values ('7e51411d-8f62-5b9d-9b08-d9cb385c939d', '4149a72e-28f1-5e61-bb94-9336f70724a4', null, '2129df38-49f8-58f0-a85e-ca9ab15a22a5', 'Inform PC of new activation', 'PC email address - pc@digitalsmiledesign.com and include pctls@digitalsmiledesign.com, as well as all mentors (Angelo, Daniel, and Marianna)', null, null, 'todo', 10000) on conflict (id) do nothing;
insert into public.task_field_values (task_id, field_id, campaign_id, value) values ('7e51411d-8f62-5b9d-9b08-d9cb385c939d', 'aaf062b3-3933-516e-8e11-3b4b88e1fea9', '4149a72e-28f1-5e61-bb94-9336f70724a4', '"Account Manager"'::jsonb) on conflict (task_id, field_id) do nothing;
insert into public.tasks (id, campaign_id, parent_id, section_id, title, description, assignee_id, due_date, status, position) values ('3b188cf1-f40b-5329-884c-abf6c3c69978', '4149a72e-28f1-5e61-bb94-9336f70724a4', null, '2129df38-49f8-58f0-a85e-ca9ab15a22a5', 'Update backend with permissions, clinic fee, and effective date of fee', '    On craft go to User
    Enter doctors name, click on their name
    click on "invoices & coins" tab
    If contract includes PC Credit, scroll down and enter PC Credit Product Group (Design+Planning, or Design+Planning+Manufacturing)

[image in the Asana original, not copied]

    Enter PC Credit Allowance (this is how much monthly credit they have included in their contract)
    Enter PC Credit Balance Note - i.e "client activated as clinic on ________, has ______ in PC credit per month"
    Click on "PC Access" tab
    Scroll down to DSD Clinics and enter clinic start date under "start date" and enter note - i.e, "DSD clinic as of _______, pays ________ per month, has _____________ included"

[image in the Asana original, not copied]', null, null, 'todo', 11000) on conflict (id) do nothing;
insert into public.task_field_values (task_id, field_id, campaign_id, value) values ('3b188cf1-f40b-5329-884c-abf6c3c69978', 'aaf062b3-3933-516e-8e11-3b4b88e1fea9', '4149a72e-28f1-5e61-bb94-9336f70724a4', '"Account Manager"'::jsonb) on conflict (task_id, field_id) do nothing;
insert into public.tasks (id, campaign_id, parent_id, section_id, title, description, assignee_id, due_date, status, position) values ('5ee98d14-bcc5-5ab0-a6dc-a75fa1cb829d', '4149a72e-28f1-5e61-bb94-9336f70724a4', '3b188cf1-f40b-5329-884c-abf6c3c69978', null, 'Enter Permissions', 'In Craft, under user, select Permissions

[image in the Asana original, not copied]

    Review the permissions already assigned, if client has a 10% permission, remove it
    Add DSD Clinic Permission
    Add MRR DSD Clinics Permission
    Add Type of Clinic permission which will be either "L3 basic (get''s one U&L per month), L3 Basic DD (this one includes 3 DD per month), or L3 Basic Inclusive Fee (pays $5000 per month and has monthly credit). 

[image in the Asana original, not copied]', null, null, 'todo', 1000) on conflict (id) do nothing;
insert into public.tasks (id, campaign_id, parent_id, section_id, title, description, assignee_id, due_date, status, position) values ('febea10b-4353-596f-9bcf-4fba71b5fae5', '4149a72e-28f1-5e61-bb94-9336f70724a4', null, '2129df38-49f8-58f0-a85e-ca9ab15a22a5', 'Update on backend clinic to MMR DSD Clinic', null, null, null, 'todo', 12000) on conflict (id) do nothing;
insert into public.task_field_values (task_id, field_id, campaign_id, value) values ('febea10b-4353-596f-9bcf-4fba71b5fae5', 'aaf062b3-3933-516e-8e11-3b4b88e1fea9', '4149a72e-28f1-5e61-bb94-9336f70724a4', '"Account Manager"'::jsonb) on conflict (task_id, field_id) do nothing;
insert into public.tasks (id, campaign_id, parent_id, section_id, title, description, assignee_id, due_date, status, position) values ('a66d0b0e-48d3-510c-9e87-3f825621afd6', '4149a72e-28f1-5e61-bb94-9336f70724a4', null, '2129df38-49f8-58f0-a85e-ca9ab15a22a5', 'Check PC Access with Carol/PM', null, null, null, 'todo', 13000) on conflict (id) do nothing;
insert into public.task_field_values (task_id, field_id, campaign_id, value) values ('a66d0b0e-48d3-510c-9e87-3f825621afd6', 'aaf062b3-3933-516e-8e11-3b4b88e1fea9', '4149a72e-28f1-5e61-bb94-9336f70724a4', '"Account Manager"'::jsonb) on conflict (task_id, field_id) do nothing;
insert into public.tasks (id, campaign_id, parent_id, section_id, title, description, assignee_id, due_date, status, position) values ('8aefcca7-cd88-50cb-884d-2ade5bed3300', '4149a72e-28f1-5e61-bb94-9336f70724a4', null, '2129df38-49f8-58f0-a85e-ca9ab15a22a5', 'Add yearly LTP products included (only if applicable!)', 'LTP included:
DSD Clinics Legacy - 0 included
DSD Clinics L3 basic - 6 per year included
DSD Clinics full contract - 2 per month included
________
DSD Provider monthly - 0 included
DSD Provider annual - 3 per year included. 

    All LTPs include 30 minutes



Pricing:
DSD Clinics Legacy - No discount
DSD Clinics L3 basic - 10% discount
DSD Clinics full contract - 25% discount
__________
DSD Providers - No discount.', null, null, 'todo', 14000) on conflict (id) do nothing;
insert into public.task_field_values (task_id, field_id, campaign_id, value) values ('8aefcca7-cd88-50cb-884d-2ade5bed3300', 'aaf062b3-3933-516e-8e11-3b4b88e1fea9', '4149a72e-28f1-5e61-bb94-9336f70724a4', '"Account Manager"'::jsonb) on conflict (task_id, field_id) do nothing;
insert into public.tasks (id, campaign_id, parent_id, section_id, title, description, assignee_id, due_date, status, position) values ('ab7ff187-8d73-58b2-bf3b-8c0cd4c39c0f', '4149a72e-28f1-5e61-bb94-9336f70724a4', null, '2129df38-49f8-58f0-a85e-ca9ab15a22a5', 'During onboarding identify point of contact in clinic', 'Who do we speak to in the practice for Invoicing, payments, ACH forms etc', null, null, 'todo', 15000) on conflict (id) do nothing;
insert into public.task_field_values (task_id, field_id, campaign_id, value) values ('ab7ff187-8d73-58b2-bf3b-8c0cd4c39c0f', 'aaf062b3-3933-516e-8e11-3b4b88e1fea9', '4149a72e-28f1-5e61-bb94-9336f70724a4', '"Account Manager"'::jsonb) on conflict (task_id, field_id) do nothing;
insert into public.tasks (id, campaign_id, parent_id, section_id, title, description, assignee_id, due_date, status, position) values ('0c7d2aa1-2e82-5098-b4e6-75b278e3d172', '4149a72e-28f1-5e61-bb94-9336f70724a4', null, '2129df38-49f8-58f0-a85e-ca9ab15a22a5', 'Provide Access to DSD Online', null, null, null, 'todo', 16000) on conflict (id) do nothing;
insert into public.task_field_values (task_id, field_id, campaign_id, value) values ('0c7d2aa1-2e82-5098-b4e6-75b278e3d172', 'aaf062b3-3933-516e-8e11-3b4b88e1fea9', '4149a72e-28f1-5e61-bb94-9336f70724a4', '"Account Manager"'::jsonb) on conflict (task_id, field_id) do nothing;
insert into public.tasks (id, campaign_id, parent_id, section_id, title, description, assignee_id, due_date, status, position) values ('f3175d0c-40c4-5c07-a186-e3cd49513953', '4149a72e-28f1-5e61-bb94-9336f70724a4', null, 'adff592b-eb38-52cd-bbcb-441926316e30', 'Build & send welcome email after ACTIVATION (without CC''s video) + HANDOVER DSD Coach???', '

Email 1: Welcome to the Next Phase (Post-Onboarding / Activation)
Subject line:
Meet Your DSD Coach & Your Next Steps
Preview text:


Dear Clinic Team,
 
Congratulations! Your DSD Clinic onboarding is complete, and your clinic has officially joined the DSD Clinic community. This milestone reflects your hard work, vision, and commitment to excellence. We''re genuinely glad to welcome you. Attached, please find your onboarding presentation for your reference. 

I am pleased to introduce your DSD Coach, [DSD Coach''s name], who is copied here. Your Coach will guide you through the DSD Coaching program. This is a structured journey designed to help your team implement DSD principles with clarity, efficiency, and motivation.
 
Your next step
Please schedule your first coaching session using [this link].

Your Coach will work alongside your team to:
    Implement DSD workflows into your daily practice
     
    Strengthen case presentation and patient communication
     
    Build consistency across your clinical team
     
    Help you maximize the clinical value of your DSD membership

In short, I''ll continue to look after the practical side of your membership, resources, and overall clinic success, while [DSD Coach name] focuses on helping your team put DSD into clinical practice day to day.

We''re proud to see you reach this point, and we look forward to everything you and your team will achieve in the months ahead.
 
Warm regards,

Your Name
DSD Account Manager

✉️ email@digitalsmiledesign.com
📞 Phone number




(Email 1 from https://docs.google.com/document/d/1uYhVIls4V7MRQlsqt4-vl2NrjxV1-9wsmtpGJXQRRRc/edit?tab=t.0)

The template for this email is DSD Clinics Email 1 Welcome to the Next Phase Post-Onboarding and Activation


----------------------------------------

How to use the Hubspot templates:


Hubspot seems to be a bit funny with the links to templates, they seem to work for a bit and then not. The easiest way is to:

    Click ''create email'' 
    Select the template you need from the screen when it asks you to choose. These are the names to look for. They should be at the top if you filter by recently updated. 

DSD Clinics Email 0 Welcome and Next Steps Pre-Onboarding

DSD Clinics Email 1 Welcome to the Next Phase Post-Onboarding and Activation

DSD Clinics Welcome Email after GRADUATION

Then, your email will be pre-populated with the correct text and you can edit every part of it, add subject line and preview text, change the sender name, update links, etc. 

Here''s a loom on how to use the template/edit the email you''ve created: https://www.loom.com/share/20c43cbd5b5a448d9a14b0091a6c92f8

The subscription type is:
Requested resources and customer updates

For the email name, an example would be:

202609-07 | CUST | EML | Dental Unit | Email 0 Welcome and Next Steps Pre-Onboarding', null, null, 'todo', 17000) on conflict (id) do nothing;
insert into public.task_field_values (task_id, field_id, campaign_id, value) values ('f3175d0c-40c4-5c07-a186-e3cd49513953', 'aaf062b3-3933-516e-8e11-3b4b88e1fea9', '4149a72e-28f1-5e61-bb94-9336f70724a4', '"Account Manager"'::jsonb) on conflict (task_id, field_id) do nothing;
insert into public.tasks (id, campaign_id, parent_id, section_id, title, description, assignee_id, due_date, status, position) values ('3f41863a-5993-5eb3-bd30-9eab5e4a48ec', '4149a72e-28f1-5e61-bb94-9336f70724a4', null, 'adff592b-eb38-52cd-bbcb-441926316e30', 'Create DCCP Coaching Ticket on Backend & Hubspot', 'Watch loom for instructions on how to do this

https://www.loom.com/share/9de6e279ece74d0ba565e4fe48574dbc?sid=b5171b4d-0072-43d1-aa28-8f5bc3a8a719

https://app.hubspot.com/workflows/3439767/platform/flow/539944737/edit


[image in the Asana original, not copied]', null, null, 'todo', 18000) on conflict (id) do nothing;
insert into public.task_field_values (task_id, field_id, campaign_id, value) values ('3f41863a-5993-5eb3-bd30-9eab5e4a48ec', 'aaf062b3-3933-516e-8e11-3b4b88e1fea9', '4149a72e-28f1-5e61-bb94-9336f70724a4', '"Account Manager"'::jsonb) on conflict (task_id, field_id) do nothing;
insert into public.tasks (id, campaign_id, parent_id, section_id, title, description, assignee_id, due_date, status, position) values ('b7a5306d-a113-5dc6-bab4-0709611a96b4', '4149a72e-28f1-5e61-bb94-9336f70724a4', null, 'adff592b-eb38-52cd-bbcb-441926316e30', 'Create Whats App Concierge Group', 'People to include in the WA Group: 

PC/LAB team (Roberto Vasquez, Alejandra and Alejandro, Carlos González, John Coachman + Ricardo Serrano) 

Delight Team ( AM + JJ )', null, null, 'todo', 19000) on conflict (id) do nothing;
insert into public.task_field_values (task_id, field_id, campaign_id, value) values ('b7a5306d-a113-5dc6-bab4-0709611a96b4', 'aaf062b3-3933-516e-8e11-3b4b88e1fea9', '4149a72e-28f1-5e61-bb94-9336f70724a4', '"Account Manager"'::jsonb) on conflict (task_id, field_id) do nothing;
insert into public.tasks (id, campaign_id, parent_id, section_id, title, description, assignee_id, due_date, status, position) values ('714be777-6cdc-5b83-9f7b-f9e5d6411bc9', '4149a72e-28f1-5e61-bb94-9336f70724a4', 'b7a5306d-a113-5dc6-bab4-0709611a96b4', null, 'Welcome WhatsApp Message Examples', 'Example 1: 

Good morning everyone! I hope you’re all having good weeks so far! 🤗

I wanted to share great news with you all, please welcome Dr. [Name], one of our newest DSD Clinics in [Country] [flag]🚀

Within DSD Clinics, we provide the highest level of support to ensure that all your needs are accommodated. 

This is your personal Whatsapp Concierge Group in which we include members of our team to ensure that all your questions are solved. Here you have direct access, among others, to Dr. Francis @Francis Coachman ⁩ ⁩Daniel Ramos and a full team of Customer Support to help you in any DSD related topics. Feel free to ask any questions you might have about the DSD workflow or discuss any Planning Center related cases. We’re all here to support you along the way!

This is one of the multiple benefits of becoming a DSD Clinic. I''ll explain everything in much more detail in our onboarding call next week! 

@DSD Dr Thomas Fiege, once again, we’re very happy to have you joining the DSD Clinics worldwide network! You’re already an admin of the group, so feel free to add anyone that you think is relevant. 

Let’s make this an exciting journey together. Onwards and upwards! 🙌🏼🔝

Example 2: 

Good morning/afternoon everyone! I hope you’re all having good weeks so far! 🤗

I wanted to share great news with you all, please welcome Dr. Samer Nuwwareh one of our newest DSD Clinics in Canada 🇨🇦🚀

Within DSD Clinics, we provide the highest level of support to ensure that all your needs are accommodated. 

This is your personal Whatsapp Concierge Group in which we include members of our team to ensure that all your questions are solved. Here you have direct access, among others, to Dr. Francis @Francis Coachman , Daniel Ramos  ⁩and a full team of Customer Support to help you in any DSD related topics. Feel free to ask any questions you might have about the DSD workflow or discuss any Planning Center related cases. We’re all here to support you along the way!

This is one of the multiple benefits of becoming a DSD Clinic. As mentioned, your DSD Clinic discounts have already been activated but I''ll explain everything in much more detail in our onboarding call! Let me know when you''re free either this week of the following one and please note I''m based in Madrid so it would be ideal if we could have our call during your morning🙏🏼

@Samer Nuwwareh, once again, we’re very happy to have you joining the DSD Clinics worldwide network! You’re already an admin of the group, so feel free to add anyone that you think is relevant. 

Let’s make this an exciting journey together. Onwards and upwards! 🙌🏼🔝

Example 3: 

Good morning everyone! I hope you’re all having good weeks so far! 🤗

I wanted to share great news with you all, please welcome Dr. Paul Lee, the first and only DSD Clinic in Luxembourg  🇱🇺🚀

Within DSD Clinics, we provide the highest level of support to ensure that all your needs are accommodated. 

This is your personal Whatsapp Concierge Group in which we include members of our team to ensure that all your questions are solved. Here you have direct access, among others, to Dr. Francis @Francis Coachman, Daniel Ramos ⁩and a full team of Customer Support to help you in any DSD related topics. Feel free to ask any questions you might have about the DSD workflow or discuss any Planning Center related cases. We’re all here to support you along the way!

This is one of the multiple benefits of becoming a DSD Clinic. I''ll explain everything in much more detail in our onboarding which we still need to schedule! 

@Dr. Paul Lee, once again, we’re very happy to have you joining the DSD Clinics worldwide network! You’re already an admin of the group, so feel free to add anyone that you think is relevant. Dr. Job, your DSD Coordinator, is in the group already.

Let’s make this an exciting journey together. Onwards and upwards! 🙌🏼🔝', null, null, 'todo', 1000) on conflict (id) do nothing;
insert into public.tasks (id, campaign_id, parent_id, section_id, title, description, assignee_id, due_date, status, position) values ('36684f61-de71-5057-a38e-88eccd30811b', '4149a72e-28f1-5e61-bb94-9336f70724a4', 'b7a5306d-a113-5dc6-bab4-0709611a96b4', null, 'Create Canva profile picture for the WA Concierge Group - Dr. Name', 'Template: https://www.canva.com/design/DAEq1uTU0Qw/wOk5LRvvQ8ij7k6LL5-Ilw/edit', null, null, 'todo', 2000) on conflict (id) do nothing;
insert into public.tasks (id, campaign_id, parent_id, section_id, title, description, assignee_id, due_date, status, position) values ('b898bed1-aeaa-5feb-8af4-d2878b5be147', '4149a72e-28f1-5e61-bb94-9336f70724a4', 'b7a5306d-a113-5dc6-bab4-0709611a96b4', null, 'Create Canva profile picture for the WA Concierge Group - Dr. Picture', null, null, null, 'todo', 3000) on conflict (id) do nothing;
insert into public.tasks (id, campaign_id, parent_id, section_id, title, description, assignee_id, due_date, status, position) values ('e8337400-045b-5f20-b0f5-5f9a96601efd', '4149a72e-28f1-5e61-bb94-9336f70724a4', 'b7a5306d-a113-5dc6-bab4-0709611a96b4', null, 'Add DSD Clinic owner to Webinars - DSD Clinics', null, null, null, 'todo', 4000) on conflict (id) do nothing;
insert into public.tasks (id, campaign_id, parent_id, section_id, title, description, assignee_id, due_date, status, position) values ('9e8ac8f0-b63d-550f-bccc-db72eb7624db', '4149a72e-28f1-5e61-bb94-9336f70724a4', 'b7a5306d-a113-5dc6-bab4-0709611a96b4', null, 'Add DSD Clinic owner to DSD Clinics - Clinical', null, null, null, 'todo', 5000) on conflict (id) do nothing;
insert into public.tasks (id, campaign_id, parent_id, section_id, title, description, assignee_id, due_date, status, position) values ('cd984fe2-0e3f-5896-bc41-ca971992fb7a', '4149a72e-28f1-5e61-bb94-9336f70724a4', 'b7a5306d-a113-5dc6-bab4-0709611a96b4', null, 'Add DSD Clinic owner to DSD Clinics - Patient Ref', null, null, null, 'todo', 6000) on conflict (id) do nothing;
insert into public.tasks (id, campaign_id, parent_id, section_id, title, description, assignee_id, due_date, status, position) values ('fdb478a8-b57e-5092-9dc9-b2d9f43abb0e', '4149a72e-28f1-5e61-bb94-9336f70724a4', 'b7a5306d-a113-5dc6-bab4-0709611a96b4', null, 'Add DSD Clinic owner to the DSD Clinic official group with a recognition message', 'Good morning/afternoon everyone! 😊👋🏼

I hope you’ve all had amazing summers! 

In Europe, September is generally known as the “back to school” or “back to reality” month! We at DSD have also had a summer break, but this doesn’t mean that we’ve stopped growing our DSD Clinics family network, so please join me in welcoming our newest DSD Clinics! 🤗🚀

This group is to share knowledge, experiences and learn from this amazing group of like-minded dentists who value innovation and differentiation. 🌍💥


[flag] Dr. [Name] (@[Name]) - [City, Country]. [One or two lines about the clinic and what makes it special.]', null, null, 'todo', 7000) on conflict (id) do nothing;
insert into public.tasks (id, campaign_id, parent_id, section_id, title, description, assignee_id, due_date, status, position) values ('d977b7a1-37b9-57c3-9eb7-a860ee9ea4f3', '4149a72e-28f1-5e61-bb94-9336f70724a4', null, 'adff592b-eb38-52cd-bbcb-441926316e30', 'Update anniversary and birthday calendars', 'Add to the specific Google Calendar the exact date when the DSD clinic was activated and when the owner was born in order to congratulate him/her during aniversaries. 

https://calendar.google.com/calendar/embed?src=c_5lrioqtr4s2toitmr37h9pamls%40group.calendar.google.com&ctz=Europe%2FMadrid', null, null, 'todo', 20000) on conflict (id) do nothing;
insert into public.task_field_values (task_id, field_id, campaign_id, value) values ('d977b7a1-37b9-57c3-9eb7-a860ee9ea4f3', 'aaf062b3-3933-516e-8e11-3b4b88e1fea9', '4149a72e-28f1-5e61-bb94-9336f70724a4', '"Account Manager"'::jsonb) on conflict (task_id, field_id) do nothing;
insert into public.tasks (id, campaign_id, parent_id, section_id, title, description, assignee_id, due_date, status, position) values ('5cf4c1f2-f0ef-5346-b6f3-3238ce2c5f4e', '4149a72e-28f1-5e61-bb94-9336f70724a4', null, 'adff592b-eb38-52cd-bbcb-441926316e30', 'Clinic plaque design', null, null, null, 'todo', 21000) on conflict (id) do nothing;
insert into public.task_field_values (task_id, field_id, campaign_id, value) values ('5cf4c1f2-f0ef-5346-b6f3-3238ce2c5f4e', 'aaf062b3-3933-516e-8e11-3b4b88e1fea9', '4149a72e-28f1-5e61-bb94-9336f70724a4', '"Marketing?"'::jsonb) on conflict (task_id, field_id) do nothing;
insert into public.tasks (id, campaign_id, parent_id, section_id, title, description, assignee_id, due_date, status, position) values ('5a25b865-c71b-5966-a4a7-564c3347d318', '4149a72e-28f1-5e61-bb94-9336f70724a4', '5cf4c1f2-f0ef-5346-b6f3-3238ce2c5f4e', null, 'Send clinic plaque design to manufacturer', null, null, null, 'todo', 1000) on conflict (id) do nothing;
insert into public.tasks (id, campaign_id, parent_id, section_id, title, description, assignee_id, due_date, status, position) values ('f089b9f8-5a18-5c63-bd08-943961019dae', '4149a72e-28f1-5e61-bb94-9336f70724a4', '5cf4c1f2-f0ef-5346-b6f3-3238ce2c5f4e', null, 'Hand written message for the plaque', null, null, null, 'todo', 2000) on conflict (id) do nothing;
insert into public.tasks (id, campaign_id, parent_id, section_id, title, description, assignee_id, due_date, status, position) values ('815381f8-5573-5328-99d6-e044afada758', '4149a72e-28f1-5e61-bb94-9336f70724a4', '5cf4c1f2-f0ef-5346-b6f3-3238ce2c5f4e', null, 'Send clinic plaque to client', null, null, null, 'todo', 3000) on conflict (id) do nothing;
insert into public.tasks (id, campaign_id, parent_id, section_id, title, description, assignee_id, due_date, status, position) values ('a20ac060-d9e5-5547-9545-75eee77d8453', '4149a72e-28f1-5e61-bb94-9336f70724a4', null, 'adff592b-eb38-52cd-bbcb-441926316e30', 'Get client assets', null, null, null, 'todo', 22000) on conflict (id) do nothing;
insert into public.task_field_values (task_id, field_id, campaign_id, value) values ('a20ac060-d9e5-5547-9545-75eee77d8453', 'aaf062b3-3933-516e-8e11-3b4b88e1fea9', '4149a72e-28f1-5e61-bb94-9336f70724a4', '"Account Manager"'::jsonb) on conflict (task_id, field_id) do nothing;
insert into public.tasks (id, campaign_id, parent_id, section_id, title, description, assignee_id, due_date, status, position) values ('00d26af9-b2f3-5549-9e7c-623a6c36088a', '4149a72e-28f1-5e61-bb94-9336f70724a4', null, 'adff592b-eb38-52cd-bbcb-441926316e30', 'Activate MKT Welcome Pack', null, null, null, 'todo', 23000) on conflict (id) do nothing;
insert into public.task_field_values (task_id, field_id, campaign_id, value) values ('00d26af9-b2f3-5549-9e7c-623a6c36088a', 'aaf062b3-3933-516e-8e11-3b4b88e1fea9', '4149a72e-28f1-5e61-bb94-9336f70724a4', '"Account Manager"'::jsonb) on conflict (task_id, field_id) do nothing;
insert into public.tasks (id, campaign_id, parent_id, section_id, title, description, assignee_id, due_date, status, position) values ('87abbb97-450f-5637-98c1-46bfde52d4cd', '4149a72e-28f1-5e61-bb94-9336f70724a4', '00d26af9-b2f3-5549-9e7c-623a6c36088a', null, 'Activate DSD Portal', null, null, null, 'todo', 1000) on conflict (id) do nothing;
insert into public.tasks (id, campaign_id, parent_id, section_id, title, description, assignee_id, due_date, status, position) values ('26e4146a-1682-5dd9-88bf-b4b97f5fc27d', '4149a72e-28f1-5e61-bb94-9336f70724a4', '00d26af9-b2f3-5549-9e7c-623a6c36088a', null, 'Activate Marketing Welcome Pack', null, null, null, 'todo', 2000) on conflict (id) do nothing;
insert into public.tasks (id, campaign_id, parent_id, section_id, title, description, assignee_id, due_date, status, position) values ('eb04cfef-b2e3-51d8-8495-89a391fbc646', '4149a72e-28f1-5e61-bb94-9336f70724a4', null, 'adff592b-eb38-52cd-bbcb-441926316e30', 'Create a ''Find a Clinic'' page', 'Both the "Add new clinic to the DSD website" and "Create ''Find a Clinic'' page" tasks are now assigned to the Account Managers.

Here a step-by-step tutorial video/guide so we can follow the process and grant the necessary permissions.

Videos to edit this page: https://www.digitalsmiledesign.clinic/find-a-clinic/

Tutorials on how to add and edit clinics on the Hubspot DSD Clinics page:
https://www.dropbox.com/work/DSD%20Marketing%20Dropbox/TRAINING/DigitalSmileDesign.clinic/Find_a%20_clinic_inner_pages?quickview=id%3AMcutGkLv6WsAAAAAAAdehg

How to delete a clinic from the Hubspot DSD Clinics page:
https://www.loom.com/share/ccfae809966342c2a9144012e57ae998', null, null, 'todo', 24000) on conflict (id) do nothing;
insert into public.task_field_values (task_id, field_id, campaign_id, value) values ('eb04cfef-b2e3-51d8-8495-89a391fbc646', 'aaf062b3-3933-516e-8e11-3b4b88e1fea9', '4149a72e-28f1-5e61-bb94-9336f70724a4', '"Account Manager"'::jsonb) on conflict (task_id, field_id) do nothing;
insert into public.tasks (id, campaign_id, parent_id, section_id, title, description, assignee_id, due_date, status, position) values ('cddd9e3f-1bbf-5d5c-8670-ff83b6ccfdb3', '4149a72e-28f1-5e61-bb94-9336f70724a4', null, 'adff592b-eb38-52cd-bbcb-441926316e30', 'Add new Clinic to ''DSD website''', 'Both the "Add new clinic to the DSD website" and "Create ''Find a Clinic'' page" tasks are now assigned to the Account Managers.

Here a step-by-step tutorial video/guide so we can follow the process and grant the necessary permissions.

Videos to edit this page: https://digitalsmiledesign.com/explore/our-community/dsd-clinics-network

How to add a clinic:
https://www.loom.com/share/0ac9c43c70a9417389af7882fd1933df

How to delete a clinic: 
https://www.loom.com/share/866ef35b80b24d78a1a226c6c84b8d6d', null, null, 'todo', 25000) on conflict (id) do nothing;
insert into public.task_field_values (task_id, field_id, campaign_id, value) values ('cddd9e3f-1bbf-5d5c-8670-ff83b6ccfdb3', 'aaf062b3-3933-516e-8e11-3b4b88e1fea9', '4149a72e-28f1-5e61-bb94-9336f70724a4', '"Account Manager"'::jsonb) on conflict (task_id, field_id) do nothing;
insert into public.tasks (id, campaign_id, parent_id, section_id, title, description, assignee_id, due_date, status, position) values ('c55dea8c-c8d1-5b58-8a4a-cb284b4dec16', '4149a72e-28f1-5e61-bb94-9336f70724a4', null, 'adff592b-eb38-52cd-bbcb-441926316e30', 'Prep image assets', null, null, null, 'todo', 26000) on conflict (id) do nothing;
insert into public.task_field_values (task_id, field_id, campaign_id, value) values ('c55dea8c-c8d1-5b58-8a4a-cb284b4dec16', 'aaf062b3-3933-516e-8e11-3b4b88e1fea9', '4149a72e-28f1-5e61-bb94-9336f70724a4', '"Marketing"'::jsonb) on conflict (task_id, field_id) do nothing;
insert into public.tasks (id, campaign_id, parent_id, section_id, title, description, assignee_id, due_date, status, position) values ('fc6c307e-99a4-55e9-831d-30fa904fc020', '4149a72e-28f1-5e61-bb94-9336f70724a4', null, 'adff592b-eb38-52cd-bbcb-441926316e30', 'Design MKT Co-Branded assets', null, null, null, 'todo', 27000) on conflict (id) do nothing;
insert into public.task_field_values (task_id, field_id, campaign_id, value) values ('fc6c307e-99a4-55e9-831d-30fa904fc020', 'aaf062b3-3933-516e-8e11-3b4b88e1fea9', '4149a72e-28f1-5e61-bb94-9336f70724a4', '"Marketing"'::jsonb) on conflict (task_id, field_id) do nothing;
insert into public.tasks (id, campaign_id, parent_id, section_id, title, description, assignee_id, due_date, status, position) values ('15a323d7-059d-58dc-8fa6-d309af513697', '4149a72e-28f1-5e61-bb94-9336f70724a4', 'fc6c307e-99a4-55e9-831d-30fa904fc020', null, 'QA MKT Co-Branded assets', null, null, null, 'todo', 1000) on conflict (id) do nothing;
insert into public.tasks (id, campaign_id, parent_id, section_id, title, description, assignee_id, due_date, status, position) values ('3e4187d7-e1b0-597f-b252-c7b0bab1077d', '4149a72e-28f1-5e61-bb94-9336f70724a4', 'fc6c307e-99a4-55e9-831d-30fa904fc020', null, 'Create MKT Co-Branded assets Notion doc', null, null, null, 'todo', 2000) on conflict (id) do nothing;
insert into public.tasks (id, campaign_id, parent_id, section_id, title, description, assignee_id, due_date, status, position) values ('55b7095b-d76c-50ee-9a22-946aba38d5a4', '4149a72e-28f1-5e61-bb94-9336f70724a4', 'fc6c307e-99a4-55e9-831d-30fa904fc020', null, 'Send/Activate MKT Co-Branded assets Notion doc', null, null, null, 'todo', 3000) on conflict (id) do nothing;
insert into public.tasks (id, campaign_id, parent_id, section_id, title, description, assignee_id, due_date, status, position) values ('f435b960-7eed-5b73-92ac-bfa5f13501f4', '4149a72e-28f1-5e61-bb94-9336f70724a4', null, 'adff592b-eb38-52cd-bbcb-441926316e30', 'PC Onboarding (if applicable)', null, null, null, 'todo', 28000) on conflict (id) do nothing;
insert into public.task_field_values (task_id, field_id, campaign_id, value) values ('f435b960-7eed-5b73-92ac-bfa5f13501f4', 'aaf062b3-3933-516e-8e11-3b4b88e1fea9', '4149a72e-28f1-5e61-bb94-9336f70724a4', '"Ricardo Serrano"'::jsonb) on conflict (task_id, field_id) do nothing;
insert into public.tasks (id, campaign_id, parent_id, section_id, title, description, assignee_id, due_date, status, position) values ('b3fe86b2-6b12-563d-b7e2-1f577ddf8ef3', '4149a72e-28f1-5e61-bb94-9336f70724a4', null, 'adff592b-eb38-52cd-bbcb-441926316e30', 'DSD Coaching ready to start: tag Carmen/Lindi', null, null, null, 'todo', 29000) on conflict (id) do nothing;
insert into public.task_field_values (task_id, field_id, campaign_id, value) values ('b3fe86b2-6b12-563d-b7e2-1f577ddf8ef3', 'aaf062b3-3933-516e-8e11-3b4b88e1fea9', '4149a72e-28f1-5e61-bb94-9336f70724a4', '"Account Manager"'::jsonb) on conflict (task_id, field_id) do nothing;
insert into public.tasks (id, campaign_id, parent_id, section_id, title, description, assignee_id, due_date, status, position) values ('2fdd6759-3b1d-5a1f-a0cb-134673f7f762', '4149a72e-28f1-5e61-bb94-9336f70724a4', null, 'adff592b-eb38-52cd-bbcb-441926316e30', 'Designate DSD Coach', null, null, null, 'todo', 30000) on conflict (id) do nothing;
insert into public.task_field_values (task_id, field_id, campaign_id, value) values ('2fdd6759-3b1d-5a1f-a0cb-134673f7f762', 'aaf062b3-3933-516e-8e11-3b4b88e1fea9', '4149a72e-28f1-5e61-bb94-9336f70724a4', '"Carmen/Lindi"'::jsonb) on conflict (task_id, field_id) do nothing;
insert into public.tasks (id, campaign_id, parent_id, section_id, title, description, assignee_id, due_date, status, position) values ('d6a81981-474b-5fb5-859c-b7cf19fbd7f0', '4149a72e-28f1-5e61-bb94-9336f70724a4', null, 'adff592b-eb38-52cd-bbcb-441926316e30', 'Share NEW Welcome/Graduation + Anniversary Canva pack (new assets)', null, null, null, 'todo', 31000) on conflict (id) do nothing;
insert into public.task_field_values (task_id, field_id, campaign_id, value) values ('d6a81981-474b-5fb5-859c-b7cf19fbd7f0', 'aaf062b3-3933-516e-8e11-3b4b88e1fea9', '4149a72e-28f1-5e61-bb94-9336f70724a4', '"Account Manager"'::jsonb) on conflict (task_id, field_id) do nothing;
insert into public.tasks (id, campaign_id, parent_id, section_id, title, description, assignee_id, due_date, status, position) values ('60437d0a-8cff-5683-9453-7d2a154ff9b8', '4149a72e-28f1-5e61-bb94-9336f70724a4', 'd6a81981-474b-5fb5-859c-b7cf19fbd7f0', null, 'Share DSD Clinic Welcome/Milestone Posts on Social Media (when tagged)', 'Task Description
Monitor DSD social channels for posts, videos, or reels created by DSD Clinics—specifically welcome, graduation, or anniversary posts where they use our official brand assets and tag Digital Smile Design.', null, null, 'todo', 1000) on conflict (id) do nothing;
insert into public.tasks (id, campaign_id, parent_id, section_id, title, description, assignee_id, due_date, status, position) values ('11909f67-da13-54e6-bead-3442c63f7deb', '4149a72e-28f1-5e61-bb94-9336f70724a4', null, '1d630e36-0957-522f-8697-c13daf594ba8', 'Onboarding Completed - Create Consultancy ticket', 'Information about the client deal to be shared with Technical Customer Support:
    Type of clinic contract
    Expenses included or not

https://www.loom.com/share/30d3232fd9614658b27671bad372ae27?sid=9f8a4eeb-7bb9-4bbf-9786-fb9028ae18a3

[image in the Asana original, not copied]


Consultancy coupon code DCCP-TEAM-CONSULTANCY', null, null, 'todo', 32000) on conflict (id) do nothing;
insert into public.task_field_values (task_id, field_id, campaign_id, value) values ('11909f67-da13-54e6-bead-3442c63f7deb', 'aaf062b3-3933-516e-8e11-3b4b88e1fea9', '4149a72e-28f1-5e61-bb94-9336f70724a4', '"Account Manager"'::jsonb) on conflict (task_id, field_id) do nothing;
insert into public.tasks (id, campaign_id, parent_id, section_id, title, description, assignee_id, due_date, status, position) values ('c943a3f6-a7a5-58ac-8bb8-7e3c6ef2b6eb', '4149a72e-28f1-5e61-bb94-9336f70724a4', null, '1d630e36-0957-522f-8697-c13daf594ba8', 'DSD Consultancy booked', null, null, null, 'todo', 33000) on conflict (id) do nothing;
insert into public.task_field_values (task_id, field_id, campaign_id, value) values ('c943a3f6-a7a5-58ac-8bb8-7e3c6ef2b6eb', 'aaf062b3-3933-516e-8e11-3b4b88e1fea9', '4149a72e-28f1-5e61-bb94-9336f70724a4', '"DSD Consultant"'::jsonb) on conflict (task_id, field_id) do nothing;
insert into public.tasks (id, campaign_id, parent_id, section_id, title, description, assignee_id, due_date, status, position) values ('29e53dff-d603-5099-b90b-57057592d681', '4149a72e-28f1-5e61-bb94-9336f70724a4', null, '1d630e36-0957-522f-8697-c13daf594ba8', 'DSD Consultancy preparation on track', null, null, null, 'todo', 34000) on conflict (id) do nothing;
insert into public.task_field_values (task_id, field_id, campaign_id, value) values ('29e53dff-d603-5099-b90b-57057592d681', 'aaf062b3-3933-516e-8e11-3b4b88e1fea9', '4149a72e-28f1-5e61-bb94-9336f70724a4', '"DSD Consultant"'::jsonb) on conflict (task_id, field_id) do nothing;
insert into public.tasks (id, campaign_id, parent_id, section_id, title, description, assignee_id, due_date, status, position) values ('f628c693-d155-5e47-8442-fbd9e9416473', '4149a72e-28f1-5e61-bb94-9336f70724a4', null, '1d630e36-0957-522f-8697-c13daf594ba8', 'DSD Consultancy completed', null, null, null, 'todo', 35000) on conflict (id) do nothing;
insert into public.task_field_values (task_id, field_id, campaign_id, value) values ('f628c693-d155-5e47-8442-fbd9e9416473', 'aaf062b3-3933-516e-8e11-3b4b88e1fea9', '4149a72e-28f1-5e61-bb94-9336f70724a4', '"DSD Consultant"'::jsonb) on conflict (task_id, field_id) do nothing;
insert into public.tasks (id, campaign_id, parent_id, section_id, title, description, assignee_id, due_date, status, position) values ('9cad588e-27fe-549b-8a7e-80e645e0b39c', '4149a72e-28f1-5e61-bb94-9336f70724a4', null, '8b0ce268-84e7-5e33-a9f6-327344f90e50', 'DSD Coaching sessions', 'Kick-off Call
Planning Session
1:1 Coaching Call
1:1 Coaching Call
1:1 Coaching Call
Final Planning Session and Graduation
+
Update properties', null, null, 'todo', 36000) on conflict (id) do nothing;
insert into public.task_field_values (task_id, field_id, campaign_id, value) values ('9cad588e-27fe-549b-8a7e-80e645e0b39c', 'aaf062b3-3933-516e-8e11-3b4b88e1fea9', '4149a72e-28f1-5e61-bb94-9336f70724a4', '"DSD Coach"'::jsonb) on conflict (task_id, field_id) do nothing;
insert into public.tasks (id, campaign_id, parent_id, section_id, title, description, assignee_id, due_date, status, position) values ('396fb479-e91b-5f17-8ad0-dac94d60d396', '4149a72e-28f1-5e61-bb94-9336f70724a4', null, '8b0ce268-84e7-5e33-a9f6-327344f90e50', 'DSD Clinic Welcome Video (to add to the email)', 'Before 
(we can start recording before to have it ready!)', null, null, 'todo', 37000) on conflict (id) do nothing;
insert into public.task_field_values (task_id, field_id, campaign_id, value) values ('396fb479-e91b-5f17-8ad0-dac94d60d396', 'aaf062b3-3933-516e-8e11-3b4b88e1fea9', '4149a72e-28f1-5e61-bb94-9336f70724a4', '"Account Manager"'::jsonb) on conflict (task_id, field_id) do nothing;
insert into public.tasks (id, campaign_id, parent_id, section_id, title, description, assignee_id, due_date, status, position) values ('92a378d3-ecfc-5554-8789-1ee13c6145f0', '4149a72e-28f1-5e61-bb94-9336f70724a4', '396fb479-e91b-5f17-8ad0-dac94d60d396', null, 'Notify and tag Carmen to organize the video recording with CC in Madrid (ONLY if available, read description!)', 'Whenever possible, request an in-person recording with Carmen in Madrid, provided that timing and Christian’s availability allow it.

If an in-person recording is not feasible, do not wait for Carmen’s availability. Instead, the Account Manager should coordinate the recording remotely, ensuring that Christian records the video himself using either his computer (webcam) or his phone and shares the final video file.', null, null, 'todo', 1000) on conflict (id) do nothing;
insert into public.tasks (id, campaign_id, parent_id, section_id, title, description, assignee_id, due_date, status, position) values ('9e8beb5e-22c3-5ba5-bcf6-8bac12c1f6ed', '4149a72e-28f1-5e61-bb94-9336f70724a4', '396fb479-e91b-5f17-8ad0-dac94d60d396', null, 'Record CC''s Welcome video', 'Welcoming the clinic and congratulating them on becoming an official DSD Clinic', null, null, 'todo', 2000) on conflict (id) do nothing;
insert into public.tasks (id, campaign_id, parent_id, section_id, title, description, assignee_id, due_date, status, position) values ('9bf7f867-4b58-51a6-96ac-ee06cade6389', '4149a72e-28f1-5e61-bb94-9336f70724a4', '396fb479-e91b-5f17-8ad0-dac94d60d396', null, 'Record AM''s Welcome video', 'Welcoming the clinic and congratulating them on becoming an official DSD Clinic', null, null, 'todo', 3000) on conflict (id) do nothing;
insert into public.tasks (id, campaign_id, parent_id, section_id, title, description, assignee_id, due_date, status, position) values ('d574aed2-2a56-5b73-8042-1825162dc5b2', '4149a72e-28f1-5e61-bb94-9336f70724a4', '396fb479-e91b-5f17-8ad0-dac94d60d396', null, 'Record JJ''s Welcome video', 'Welcoming the clinic and congratulating them on becoming an official DSD Clinic', null, null, 'todo', 4000) on conflict (id) do nothing;
insert into public.tasks (id, campaign_id, parent_id, section_id, title, description, assignee_id, due_date, status, position) values ('f974f28b-6901-5797-9b10-9439e70593f0', '4149a72e-28f1-5e61-bb94-9336f70724a4', '396fb479-e91b-5f17-8ad0-dac94d60d396', null, 'Notify another relevant DSD representative to record the Welcome video (Daniel Ramos, Angelo, Luken)', '(e.g., Daniel Ramos, Angelo Rafael, or another appropriate team member) welcoming the clinic and congratulating them on becoming an official DSD Clinic', null, null, 'todo', 5000) on conflict (id) do nothing;
insert into public.tasks (id, campaign_id, parent_id, section_id, title, description, assignee_id, due_date, status, position) values ('63d7cbea-008f-5048-a97b-7518ca3a6c2e', '4149a72e-28f1-5e61-bb94-9336f70724a4', '396fb479-e91b-5f17-8ad0-dac94d60d396', null, 'Edit + Upload in Vimeo the video', 'Compile all the welcome videos received and edit them into a single video using iMovie or a similar editing tool. Add a DSD Clinics intro slide or cover if needed, and make any basic edits required to ensure a polished final result.

Once the video is finalized, upload it to Vimeo, copy the shareable link, and include it in the onboarding email sent after the DSD Coaching session.', null, null, 'todo', 6000) on conflict (id) do nothing;
insert into public.tasks (id, campaign_id, parent_id, section_id, title, description, assignee_id, due_date, status, position) values ('8550d10f-2e3f-5bd9-a854-cb65b79da2b4', '4149a72e-28f1-5e61-bb94-9336f70724a4', '396fb479-e91b-5f17-8ad0-dac94d60d396', null, 'Share Welcome Video', null, null, null, 'todo', 7000) on conflict (id) do nothing;
insert into public.tasks (id, campaign_id, parent_id, section_id, title, description, assignee_id, due_date, status, position) values ('280e192c-8e60-5f23-9e0c-156397956554', '4149a72e-28f1-5e61-bb94-9336f70724a4', null, '29dd0337-6f69-529a-b36b-65556e673840', 'Graduation date (DSD Coaching)', null, null, null, 'todo', 38000) on conflict (id) do nothing;
insert into public.task_field_values (task_id, field_id, campaign_id, value) values ('280e192c-8e60-5f23-9e0c-156397956554', 'aaf062b3-3933-516e-8e11-3b4b88e1fea9', '4149a72e-28f1-5e61-bb94-9336f70724a4', '"DSD Coach"'::jsonb) on conflict (task_id, field_id) do nothing;
insert into public.tasks (id, campaign_id, parent_id, section_id, title, description, assignee_id, due_date, status, position) values ('52fb2c22-cf29-5007-af04-455060a6779b', '4149a72e-28f1-5e61-bb94-9336f70724a4', '280e192c-8e60-5f23-9e0c-156397956554', null, 'Name of the clinic + list of graduates DSD Coaching', null, null, null, 'todo', 1000) on conflict (id) do nothing;
insert into public.tasks (id, campaign_id, parent_id, section_id, title, description, assignee_id, due_date, status, position) values ('ab490159-4dca-5ddf-987e-06e26c2a9cb2', '4149a72e-28f1-5e61-bb94-9336f70724a4', null, '29dd0337-6f69-529a-b36b-65556e673840', 'Create the DSD Coaching Graduation Certificates', 'Design certificates in Canva: https://www.canva.com/design/DAG1xcVkPsw/7ZjyP9dOt8cYC40BbvDn2Q/edit?utm_content=DAG1xcVkPsw&utm_campaign=designshare&utm_medium=link2&utm_source=sharebutton
- One generic certificate for the clinic.
- One personalized certificate per Coaching participant.
Upload all certificates to Dropbox and share the link with the Account Manager.', null, null, 'todo', 39000) on conflict (id) do nothing;
insert into public.task_field_values (task_id, field_id, campaign_id, value) values ('ab490159-4dca-5ddf-987e-06e26c2a9cb2', 'aaf062b3-3933-516e-8e11-3b4b88e1fea9', '4149a72e-28f1-5e61-bb94-9336f70724a4', '"DSD Coach"'::jsonb) on conflict (task_id, field_id) do nothing;
insert into public.tasks (id, campaign_id, parent_id, section_id, title, description, assignee_id, due_date, status, position) values ('0a7d86a4-c0b0-543f-800d-7cc1a78bf983', '4149a72e-28f1-5e61-bb94-9336f70724a4', 'ab490159-4dca-5ddf-987e-06e26c2a9cb2', null, 'Design DSD Coaching Certificates (general for the DSD Clinic + individual for each member in Coaching)', null, null, null, 'todo', 1000) on conflict (id) do nothing;
insert into public.tasks (id, campaign_id, parent_id, section_id, title, description, assignee_id, due_date, status, position) values ('2b516c55-fbcc-5c2d-9617-fef3638bbbf4', '4149a72e-28f1-5e61-bb94-9336f70724a4', 'ab490159-4dca-5ddf-987e-06e26c2a9cb2', null, 'Create link to download DSD Coaching Certificates (Dropbox)', null, null, null, 'todo', 2000) on conflict (id) do nothing;
insert into public.tasks (id, campaign_id, parent_id, section_id, title, description, assignee_id, due_date, status, position) values ('22826294-ca92-53b3-bb6e-611dfbfaa372', '4149a72e-28f1-5e61-bb94-9336f70724a4', null, '29dd0337-6f69-529a-b36b-65556e673840', 'Write HubSpot summary + update properties', 'Use the official ChatGPT prompt to generate the final Coaching summary: https://docs.google.com/document/d/1VCrZnoPUOqxgOUUJb4ju0K5Ud_xU7CMvkcGXctMR0Og/edit?usp=sharing
Upload the summary as a note in the clinic’s HubSpot profile.', null, null, 'todo', 40000) on conflict (id) do nothing;
insert into public.task_field_values (task_id, field_id, campaign_id, value) values ('22826294-ca92-53b3-bb6e-611dfbfaa372', 'aaf062b3-3933-516e-8e11-3b4b88e1fea9', '4149a72e-28f1-5e61-bb94-9336f70724a4', '"DSD Coach"'::jsonb) on conflict (task_id, field_id) do nothing;
insert into public.tasks (id, campaign_id, parent_id, section_id, title, description, assignee_id, due_date, status, position) values ('5d2d46f4-922c-5b2e-9fb5-8eaa7dc83082', '4149a72e-28f1-5e61-bb94-9336f70724a4', null, '29dd0337-6f69-529a-b36b-65556e673840', 'Prepare and send the final Graduation email to the clinic', 'Use the ChatGPT prompt to create the Final Graduation Email: https://docs.google.com/document/d/1VCrZnoPUOqxgOUUJb4ju0K5Ud_xU7CMvkcGXctMR0Og/edit?usp=sharing
Include: recap, achievements, next steps, congratulations, and the link for the follow-up call.
Send it to the clinic as the official closure message.', null, null, 'todo', 41000) on conflict (id) do nothing;
insert into public.task_field_values (task_id, field_id, campaign_id, value) values ('5d2d46f4-922c-5b2e-9fb5-8eaa7dc83082', 'aaf062b3-3933-516e-8e11-3b4b88e1fea9', '4149a72e-28f1-5e61-bb94-9336f70724a4', '"DSD Coach"'::jsonb) on conflict (task_id, field_id) do nothing;
insert into public.tasks (id, campaign_id, parent_id, section_id, title, description, assignee_id, due_date, status, position) values ('fe6a10e6-3e5c-51af-b392-46bf2269b1cf', '4149a72e-28f1-5e61-bb94-9336f70724a4', null, '29dd0337-6f69-529a-b36b-65556e673840', 'Notify the DSD internal team in Rocket', 'Post a message in Rocket announcing the graduation.
Include key notes: clinic name, Scorecard highlights, and any other relevant information.', null, null, 'todo', 42000) on conflict (id) do nothing;
insert into public.task_field_values (task_id, field_id, campaign_id, value) values ('fe6a10e6-3e5c-51af-b392-46bf2269b1cf', 'aaf062b3-3933-516e-8e11-3b4b88e1fea9', '4149a72e-28f1-5e61-bb94-9336f70724a4', '"DSD Coach"'::jsonb) on conflict (task_id, field_id) do nothing;
insert into public.tasks (id, campaign_id, parent_id, section_id, title, description, assignee_id, due_date, status, position) values ('ad591372-fe83-536b-b73c-44de1d23bb79', '4149a72e-28f1-5e61-bb94-9336f70724a4', null, '29dd0337-6f69-529a-b36b-65556e673840', 'Send to the DSD Clinic the Coaching Feedback Form', 'Send the official Coaching Feedback Form to one clinic representative (ideally the owner): https://digitalsmiledesign.typeform.com/dsdcoaching', null, null, 'todo', 43000) on conflict (id) do nothing;
insert into public.task_field_values (task_id, field_id, campaign_id, value) values ('ad591372-fe83-536b-b73c-44de1d23bb79', 'aaf062b3-3933-516e-8e11-3b4b88e1fea9', '4149a72e-28f1-5e61-bb94-9336f70724a4', '"DSD Coach"'::jsonb) on conflict (task_id, field_id) do nothing;
insert into public.tasks (id, campaign_id, parent_id, section_id, title, description, assignee_id, due_date, status, position) values ('9b6eea63-4bd0-5420-9014-cb175f0259fd', '4149a72e-28f1-5e61-bb94-9336f70724a4', null, '29dd0337-6f69-529a-b36b-65556e673840', 'Update all internal records', 'Complete the following tracking documents:
- Consumption Spreadsheet
- Scorecards tracking sheet
- Feedback Spreadsheet
EMEA + APAC: https://docs.google.com/spreadsheets/d/1EKcyksw4zXZOIlUxoIWRvj-Kgaek9eEgGoLTeFowoVk/edit?usp=sharing
AMERICAS: https://docs.google.com/spreadsheets/d/1FBu-ujIsutO8jKoP-2YcS_T7qOraiRvsUJaQiZvx4po/edit?usp=sharing', null, null, 'todo', 44000) on conflict (id) do nothing;
insert into public.task_field_values (task_id, field_id, campaign_id, value) values ('9b6eea63-4bd0-5420-9014-cb175f0259fd', 'aaf062b3-3933-516e-8e11-3b4b88e1fea9', '4149a72e-28f1-5e61-bb94-9336f70724a4', '"DSD Coach"'::jsonb) on conflict (task_id, field_id) do nothing;
insert into public.tasks (id, campaign_id, parent_id, section_id, title, description, assignee_id, due_date, status, position) values ('f9d2b0fd-b5d6-5dd3-99c2-7c33bde87093', '4149a72e-28f1-5e61-bb94-9336f70724a4', null, '29dd0337-6f69-529a-b36b-65556e673840', 'Add and tag them in the final Asana Coaching task ''FINAL. From ''Being Coached'' to ''Leading Your Own Growth''', 'This task celebrates the completion of the Coaching journey and introduces the clinic’s next phase: self-leadership and continuous growth.', null, null, 'todo', 45000) on conflict (id) do nothing;
insert into public.task_field_values (task_id, field_id, campaign_id, value) values ('f9d2b0fd-b5d6-5dd3-99c2-7c33bde87093', 'aaf062b3-3933-516e-8e11-3b4b88e1fea9', '4149a72e-28f1-5e61-bb94-9336f70724a4', '"DSD Coach"'::jsonb) on conflict (task_id, field_id) do nothing;
insert into public.tasks (id, campaign_id, parent_id, section_id, title, description, assignee_id, due_date, status, position) values ('ba43142d-fa65-53a8-a59e-3d0a49ae791e', '4149a72e-28f1-5e61-bb94-9336f70724a4', null, '29dd0337-6f69-529a-b36b-65556e673840', 'Update the HubSpot ticket (DSD Coaching Dashboard)', null, null, null, 'todo', 46000) on conflict (id) do nothing;
insert into public.task_field_values (task_id, field_id, campaign_id, value) values ('ba43142d-fa65-53a8-a59e-3d0a49ae791e', 'aaf062b3-3933-516e-8e11-3b4b88e1fea9', '4149a72e-28f1-5e61-bb94-9336f70724a4', '"DSD Coach"'::jsonb) on conflict (task_id, field_id) do nothing;
insert into public.tasks (id, campaign_id, parent_id, section_id, title, description, assignee_id, due_date, status, position) values ('b320e14a-65f6-5ede-8244-adc8c7a4cbe4', '4149a72e-28f1-5e61-bb94-9336f70724a4', null, '29dd0337-6f69-529a-b36b-65556e673840', 'Build & send welcome email after GRADUATION (+ CC''s video) + link with CERTIFICATES link', 'Copy for the email:

Subject: You did it — congrats on completing the DSD Clinics Coaching Program 🎉
Preheader: After months of work, you''ve graduated, and your next chapter begins today.
Dear [Clinic Name] Team,
Congratulations. Your clinic has officially graduated from DSD Coaching. What you achieved took time, grit, and teamwork: late hours, new habits, and hard choices. We see it, and we celebrate it with you.
A welcome from DSD''s founder
To mark this milestone, Christian Coachman, founder of DSD, recorded a short message for your team.
▶️ Watch the 60-second welcome → [Video link]
This milestone is much more than a badge. It''s the visible sign of an internal transformation, a shift in mindset that will keep you growing:
    Celebrate and share: make progress visible to the team and to your patients.
    Self-observe and self-evaluate: look honestly at what''s working and what''s not.
    Detect needs, priorities, and obstacles: choose what matters next.
    Plan, organise, and delegate well: align responsibilities and timelines.
    Meet deadlines, or have a plan if you don''t: stay accountable, and adjust deliberately when things change.
As a coaching certified DSD Clinic, you now stand within a global network of excellence: clinics that design smiles with clarity, precision, and empathy. We hope you feel proud of how far you''ve come and ready for what comes next.
What''s next
    Download your digital DSD Coaching certificates here → [link]
    Announce your milestone to your patients (email and social). We''ve attached copy and captions you can use.
    Add the DSD Clinic logo to your website, email signatures, and office displays, if you haven''t done so already.
    Schedule a call with me, your DSD Account Manager, to discuss your 90 day goals and align on how we can make that happen. → [link]
We''re honoured to have walked this path with you. Here''s to the smiles you''ll create in the months ahead.
With admiration,
The DSD Team


----------------------------------------


The template for this email is called: DSD Clinics Welcome Email after GRADUATION


----------------------------------------

Instructions for how to use the templates:


Hubspot seems to be a bit funny with the links to templates, they seem to work for a bit and then not. The easiest way is to:

    Click ''create email'' 
    Select the template you need from the screen when it asks you to choose. These are the names to look for. They should be at the top if you filter by recently updated. 

DSD Clinics Email 0 Welcome and Next Steps Pre-Onboarding

DSD Clinics Email 1 Welcome to the Next Phase Post-Onboarding and Activation

DSD Clinics Welcome Email after GRADUATION 

Then, your email will be pre-populated with the correct text and you can edit every part of it, add subject line and preview text, change the sender name, update links, etc. 

Here''s a loom on how to use the template/edit the email you''ve created: https://www.loom.com/share/20c43cbd5b5a448d9a14b0091a6c92f8

The subscription type is:
Requested resources and customer updates

For the email name, an example would be:

202609-07 | CUST | EML | Dental Unit | Email 0 Welcome and Next Steps Pre-Onboarding', null, null, 'todo', 47000) on conflict (id) do nothing;
insert into public.task_field_values (task_id, field_id, campaign_id, value) values ('b320e14a-65f6-5ede-8244-adc8c7a4cbe4', 'aaf062b3-3933-516e-8e11-3b4b88e1fea9', '4149a72e-28f1-5e61-bb94-9336f70724a4', '"Account Manager"'::jsonb) on conflict (task_id, field_id) do nothing;
insert into public.tasks (id, campaign_id, parent_id, section_id, title, description, assignee_id, due_date, status, position) values ('c3eea8d2-4bec-51ab-9cfe-1345dce3ecec', '4149a72e-28f1-5e61-bb94-9336f70724a4', null, '29dd0337-6f69-529a-b36b-65556e673840', 'Onboarding call: Post-Coaching AM check-in CALL', null, null, null, 'todo', 48000) on conflict (id) do nothing;
insert into public.task_field_values (task_id, field_id, campaign_id, value) values ('c3eea8d2-4bec-51ab-9cfe-1345dce3ecec', 'aaf062b3-3933-516e-8e11-3b4b88e1fea9', '4149a72e-28f1-5e61-bb94-9336f70724a4', '"Account Manager"'::jsonb) on conflict (task_id, field_id) do nothing;
insert into public.tasks (id, campaign_id, parent_id, section_id, title, description, assignee_id, due_date, status, position) values ('03d14a36-9c45-567a-bff7-ea4b856f76e0', '4149a72e-28f1-5e61-bb94-9336f70724a4', null, '29dd0337-6f69-529a-b36b-65556e673840', 'Social Media announcement', null, null, null, 'todo', 49000) on conflict (id) do nothing;
insert into public.task_field_values (task_id, field_id, campaign_id, value) values ('03d14a36-9c45-567a-bff7-ea4b856f76e0', 'aaf062b3-3933-516e-8e11-3b4b88e1fea9', '4149a72e-28f1-5e61-bb94-9336f70724a4', '"Marita"'::jsonb) on conflict (task_id, field_id) do nothing;
insert into public.tasks (id, campaign_id, parent_id, section_id, title, description, assignee_id, due_date, status, position) values ('d14ad457-f40d-5fee-a84f-9797b174ece7', '4149a72e-28f1-5e61-bb94-9336f70724a4', '03d14a36-9c45-567a-bff7-ea4b856f76e0', null, 'Get quote from doctor about becoming DSD Clinic', null, null, null, 'todo', 1000) on conflict (id) do nothing;
insert into public.tasks (id, campaign_id, parent_id, section_id, title, description, assignee_id, due_date, status, position) values ('d9ff8d80-5d68-5d1b-8742-2b42bc4f91f6', '4149a72e-28f1-5e61-bb94-9336f70724a4', '03d14a36-9c45-567a-bff7-ea4b856f76e0', null, 'Collate info for guide', null, null, null, 'todo', 2000) on conflict (id) do nothing;
insert into public.tasks (id, campaign_id, parent_id, section_id, title, description, assignee_id, due_date, status, position) values ('c98615e7-8527-5c05-8eaa-9be60bcf596b', '4149a72e-28f1-5e61-bb94-9336f70724a4', '03d14a36-9c45-567a-bff7-ea4b856f76e0', null, 'Create guide in Canva', null, null, null, 'todo', 3000) on conflict (id) do nothing;
insert into public.tasks (id, campaign_id, parent_id, section_id, title, description, assignee_id, due_date, status, position) values ('2ecc61b3-217d-5a12-a28e-3a8caa427e1b', '4149a72e-28f1-5e61-bb94-9336f70724a4', '03d14a36-9c45-567a-bff7-ea4b856f76e0', null, 'QA guide', null, null, null, 'todo', 4000) on conflict (id) do nothing;
insert into public.tasks (id, campaign_id, parent_id, section_id, title, description, assignee_id, due_date, status, position) values ('63850471-7b2a-536e-8cbb-8b8823714993', '4149a72e-28f1-5e61-bb94-9336f70724a4', '03d14a36-9c45-567a-bff7-ea4b856f76e0', null, 'Get approval from client', null, null, null, 'todo', 5000) on conflict (id) do nothing;
insert into public.tasks (id, campaign_id, parent_id, section_id, title, description, assignee_id, due_date, status, position) values ('b5c938a5-2361-511d-95c1-e43750ff0505', '4149a72e-28f1-5e61-bb94-9336f70724a4', '03d14a36-9c45-567a-bff7-ea4b856f76e0', null, 'Write announcement post', null, null, null, 'todo', 6000) on conflict (id) do nothing;
insert into public.tasks (id, campaign_id, parent_id, section_id, title, description, assignee_id, due_date, status, position) values ('fc70aff7-73b8-5e1c-a312-973f64f4ced6', '4149a72e-28f1-5e61-bb94-9336f70724a4', '03d14a36-9c45-567a-bff7-ea4b856f76e0', null, 'Schedule and share guide on Social Media', null, null, null, 'todo', 7000) on conflict (id) do nothing;
insert into public.tasks (id, campaign_id, parent_id, section_id, title, description, assignee_id, due_date, status, position) values ('7577ca51-e21f-5d7e-97bd-58ff9a2e7efc', '4149a72e-28f1-5e61-bb94-9336f70724a4', '03d14a36-9c45-567a-bff7-ea4b856f76e0', null, 'Share the post in the DSD Clinics Official WA group', null, null, null, 'todo', 8000) on conflict (id) do nothing;

-- Clinic Offboarding
insert into public.campaigns (id, name, description, department_id, for_department_id, status, start_date, end_date, owner_id, planned_hours, private, is_template)
values ('3b62c326-1bb6-50f5-afff-5e998d9b079d', 'Clinic Offboarding', 'Offboarding of a DSD Clinic that leaves the network: Delight and Marketing steps. Name the project “[Clinic name] - Clinic Offboarding”.', public.department_id_for('delight'), public.department_id_for('delight'), 'planned', '2026-01-05', '2026-02-05', (select id from public.people where lower(email) like 'csolla@%' limit 1), 0, false, true)
on conflict (id) do nothing;
insert into public.sections (id, campaign_id, name, position) values ('e96cb13d-170c-5103-a2bf-dffc9dea1dc0', '3b62c326-1bb6-50f5-afff-5e998d9b079d', 'Delight', 1000) on conflict (id) do nothing;
insert into public.sections (id, campaign_id, name, position) values ('c6dbfb87-96a7-5622-bbf9-be93daab2267', '3b62c326-1bb6-50f5-afff-5e998d9b079d', 'Marketing', 2000) on conflict (id) do nothing;
insert into public.tasks (id, campaign_id, parent_id, section_id, title, description, assignee_id, due_date, status, position) values ('ec0d4fd3-0506-594f-be9b-006a2fe12116', '3b62c326-1bb6-50f5-afff-5e998d9b079d', null, 'e96cb13d-170c-5103-a2bf-dffc9dea1dc0', 'Termination letter', 'Usually done by: Elisa Bedin

Log into Pandadoc and generate Termination Letter from the template, fill out the corresponding fields, download and email to client on effective date of  termination', (select id from public.people where active and lower(name) = lower('Elisa Bedin') limit 1), null, 'todo', 1000) on conflict (id) do nothing;
insert into public.tasks (id, campaign_id, parent_id, section_id, title, description, assignee_id, due_date, status, position) values ('0a93ba6e-4ea8-5d99-ade2-89c9b5a30d37', '3b62c326-1bb6-50f5-afff-5e998d9b079d', null, 'e96cb13d-170c-5103-a2bf-dffc9dea1dc0', 'Send Exit Interview to Client', 'Usually done by: Elisa Bedin

Inform client of exit interview and email link. Explain as a company we always want to better understand our client''s motives for leaving. 

Exit Interview Link - https://digitalsmiledesign.typeform.com/to/vhLWVa6J', (select id from public.people where active and lower(name) = lower('Elisa Bedin') limit 1), null, 'todo', 2000) on conflict (id) do nothing;
insert into public.tasks (id, campaign_id, parent_id, section_id, title, description, assignee_id, due_date, status, position) values ('15b580d6-abb3-5917-853f-c9f8b79b4afd', '3b62c326-1bb6-50f5-afff-5e998d9b079d', null, 'e96cb13d-170c-5103-a2bf-dffc9dea1dc0', 'Finance Review/Growth', 'Usually done by: Elisa Bedin', (select id from public.people where active and lower(name) = lower('Elisa Bedin') limit 1), null, 'todo', 3000) on conflict (id) do nothing;
insert into public.tasks (id, campaign_id, parent_id, section_id, title, description, assignee_id, due_date, status, position) values ('7a05127f-5a8d-5dcd-91ee-67547d595736', '3b62c326-1bb6-50f5-afff-5e998d9b079d', '15b580d6-abb3-5917-853f-c9f8b79b4afd', null, 'Debt Review', '
    Coordinate with Finance and Delight.
    Confirm and resolve any open debts (controlled or negotiated).', null, null, 'todo', 1000) on conflict (id) do nothing;
insert into public.tasks (id, campaign_id, parent_id, section_id, title, description, assignee_id, due_date, status, position) values ('48ae9e55-7dd0-5028-a372-48066c1f6100', '3b62c326-1bb6-50f5-afff-5e998d9b079d', '15b580d6-abb3-5917-853f-c9f8b79b4afd', null, 'Product Access Review', '
    Review all PC products assigned to the client.
    Remove or adjust based on offboarding agreement.', null, null, 'todo', 2000) on conflict (id) do nothing;
insert into public.tasks (id, campaign_id, parent_id, section_id, title, description, assignee_id, due_date, status, position) values ('3eeb8d95-aecb-5e20-a196-03607911fc98', '3b62c326-1bb6-50f5-afff-5e998d9b079d', null, 'e96cb13d-170c-5103-a2bf-dffc9dea1dc0', 'Update Hubspot', 'Usually done by: Elisa Bedin', (select id from public.people where active and lower(name) = lower('Elisa Bedin') limit 1), null, 'todo', 4000) on conflict (id) do nothing;
insert into public.tasks (id, campaign_id, parent_id, section_id, title, description, assignee_id, due_date, status, position) values ('824ebcda-f9d7-5be0-a7e0-6c96c57acc46', '3b62c326-1bb6-50f5-afff-5e998d9b079d', '3eeb8d95-aecb-5e20-a196-03607911fc98', null, 'Change DSD Clinic Status to "Ex DSD Clinic"', 'Usually done by: Elisa Bedin

You will need to change this in two places in Hubspot under the Company record
    Under "about this company" (left side of screen in client''s company profile)
    Under "DSD Clinic" (left side of screen in client''s company profile)

[image in the Asana original, not copied]

[image in the Asana original, not copied]', (select id from public.people where active and lower(name) = lower('Elisa Bedin') limit 1), null, 'todo', 1000) on conflict (id) do nothing;
insert into public.tasks (id, campaign_id, parent_id, section_id, title, description, assignee_id, due_date, status, position) values ('2bc65bff-c993-57e4-b5d8-03dc0e4a5c29', '3b62c326-1bb6-50f5-afff-5e998d9b079d', '3eeb8d95-aecb-5e20-a196-03607911fc98', null, 'Enter DSD Clinic Stop Date in the corresponding field', 'Usually done by: Elisa Bedin

[image in the Asana original, not copied]

Enter the effective date they stopped being a clinic NOT the date they gave notice.', (select id from public.people where active and lower(name) = lower('Elisa Bedin') limit 1), null, 'todo', 2000) on conflict (id) do nothing;
insert into public.tasks (id, campaign_id, parent_id, section_id, title, description, assignee_id, due_date, status, position) values ('49f71046-8204-5b52-88c0-191c9095e38c', '3b62c326-1bb6-50f5-afff-5e998d9b079d', '3eeb8d95-aecb-5e20-a196-03607911fc98', null, 'Under "Type of Clinic Contract" select Churn, and remove prior option that was there', 'Usually done by: Elisa Bedin

[image in the Asana original, not copied]', (select id from public.people where active and lower(name) = lower('Elisa Bedin') limit 1), null, 'todo', 3000) on conflict (id) do nothing;
insert into public.tasks (id, campaign_id, parent_id, section_id, title, description, assignee_id, due_date, status, position) values ('76071eab-39d7-5339-8d93-d794c3eec55c', '3b62c326-1bb6-50f5-afff-5e998d9b079d', '3eeb8d95-aecb-5e20-a196-03607911fc98', null, 'Document, under notes, why client churned and all retention efforts. Tag Michelle Carpio, and JJ Gomez on the note', 'Usually done by: Elisa Bedin', (select id from public.people where active and lower(name) = lower('Elisa Bedin') limit 1), null, 'todo', 4000) on conflict (id) do nothing;
insert into public.tasks (id, campaign_id, parent_id, section_id, title, description, assignee_id, due_date, status, position) values ('c2370053-803c-539d-acbb-0bc381d27fe5', '3b62c326-1bb6-50f5-afff-5e998d9b079d', '3eeb8d95-aecb-5e20-a196-03607911fc98', null, 'Assign Growth Rep and add notes', 'On HubSpot, assign a Growth Rep to the client.

After: Leave a note in HS, tagging the relevant person (e.g. Carol Watzo, Antonio P. ) and include:

Summary of off boarding
Any updated DSD relationship terms
Status of debts, PC access exceptions, or other important notes', null, null, 'todo', 5000) on conflict (id) do nothing;
insert into public.tasks (id, campaign_id, parent_id, section_id, title, description, assignee_id, due_date, status, position) values ('94360f36-2a2f-57e2-b6b7-e3ee45daae45', '3b62c326-1bb6-50f5-afff-5e998d9b079d', null, 'e96cb13d-170c-5103-a2bf-dffc9dea1dc0', 'Update backend', 'Usually done by: Elisa Bedin', (select id from public.people where active and lower(name) = lower('Elisa Bedin') limit 1), null, 'todo', 5000) on conflict (id) do nothing;
insert into public.tasks (id, campaign_id, parent_id, section_id, title, description, assignee_id, due_date, status, position) values ('72c3256e-b35e-5c3e-b6c7-07ee787d3c22', '3b62c326-1bb6-50f5-afff-5e998d9b079d', '94360f36-2a2f-57e2-b6b7-e3ee45daae45', null, 'Update clinic fee', 'Usually done by: Elisa Bedin

On the back end, under users profile:
    click on PC access tab
    remove clinic start date and clinic fee
    Enter note under "DSD Clinic Note" of clinic churn and effective date.', (select id from public.people where active and lower(name) = lower('Elisa Bedin') limit 1), null, 'todo', 1000) on conflict (id) do nothing;
insert into public.tasks (id, campaign_id, parent_id, section_id, title, description, assignee_id, due_date, status, position) values ('13278686-58ac-558b-9d14-80c230d9618d', '3b62c326-1bb6-50f5-afff-5e998d9b079d', '94360f36-2a2f-57e2-b6b7-e3ee45daae45', null, 'Remove permissions', 'Usually done by: Elisa Bedin

Under client''s profile on back end:
    click on "permissions" tab
    Uncheck the following:
        DSD Clinic
        DSD Clinics (zone C) - if applicable
        Level 3 Basic or Level 3 Inclusive Fee - whichever applies
        MRR DSD Clinics
        U&L, U-SD, U-UL-SD. U-UL-SD-DI3IN - if applicable and whichever applies
Extra attention to these permissions and steps:
    Remove the client from:
        ❌ All DSD Clinic groups
        ❌ Level 2 or 3 products
        ❌ DSD 10%
        ❌ PC Access (if removed)
    Keep all other permissions unchanged.
    If PC Access is retained:
        Update end date and user group accordingly.
        Add note in Craft explaining the reason for access.

    PC End Date → Set to:
        Past date (preferably last day of DSD Clinics contract).
    PC Note → Add:
        “End of DSD Clinics contract.”
    PC Certification Status → Set to:
        Certified (all clients who opened a case in the last 5 years).
    PC Certification End Date → Leave blank.
    DSD Online End Date → Set to:
        Past date (usually last day of contract).', (select id from public.people where active and lower(name) = lower('Elisa Bedin') limit 1), null, 'todo', 2000) on conflict (id) do nothing;
insert into public.tasks (id, campaign_id, parent_id, section_id, title, description, assignee_id, due_date, status, position) values ('d40fb8b3-64bc-5a45-b6b8-49655036e31b', '3b62c326-1bb6-50f5-afff-5e998d9b079d', '94360f36-2a2f-57e2-b6b7-e3ee45daae45', null, 'Remove from user groups and permissions', null, null, null, 'todo', 3000) on conflict (id) do nothing;
insert into public.tasks (id, campaign_id, parent_id, section_id, title, description, assignee_id, due_date, status, position) values ('00774b52-f38c-5a64-821e-ae9d1ff15fc2', '3b62c326-1bb6-50f5-afff-5e998d9b079d', '94360f36-2a2f-57e2-b6b7-e3ee45daae45', null, 'Remove clinic portal and any active licenses', 'Usually done by: Elisa Bedin

On the backend:
Go to → Entries:
Type in Clinics name and click disable on the right corner. 

Go to → Digital Products → Licenses:
Type in Clinics name and disable all Licenses associated to the Clinics name. 


[image in the Asana original, not copied]



[image in the Asana original, not copied]



[image in the Asana original, not copied]', (select id from public.people where active and lower(name) = lower('Elisa Bedin') limit 1), null, 'todo', 4000) on conflict (id) do nothing;
insert into public.tasks (id, campaign_id, parent_id, section_id, title, description, assignee_id, due_date, status, position) values ('4cdad9be-c932-54ac-addf-e9d1704ca8b1', '3b62c326-1bb6-50f5-afff-5e998d9b079d', '94360f36-2a2f-57e2-b6b7-e3ee45daae45', null, 'Disable any discount codes on account', 'Usually done by: Elisa Bedin', (select id from public.people where active and lower(name) = lower('Elisa Bedin') limit 1), null, 'todo', 5000) on conflict (id) do nothing;
insert into public.tasks (id, campaign_id, parent_id, section_id, title, description, assignee_id, due_date, status, position) values ('12bab381-96db-5c0c-8f80-b2f20b326e75', '3b62c326-1bb6-50f5-afff-5e998d9b079d', null, 'e96cb13d-170c-5103-a2bf-dffc9dea1dc0', 'Terminate clinic fees', 'Usually done by: Valeria Evangelista', (select id from public.people where active and lower(name) = lower('Valeria Evangelista') limit 1), null, 'todo', 6000) on conflict (id) do nothing;
insert into public.tasks (id, campaign_id, parent_id, section_id, title, description, assignee_id, due_date, status, position) values ('1d7ee466-5ba9-55fd-8d52-e9809486e799', '3b62c326-1bb6-50f5-afff-5e998d9b079d', null, 'e96cb13d-170c-5103-a2bf-dffc9dea1dc0', 'Remove from concierge Whatsapp groups', 'Usually done by: Elisa Bedin', (select id from public.people where active and lower(name) = lower('Elisa Bedin') limit 1), null, 'todo', 7000) on conflict (id) do nothing;
insert into public.tasks (id, campaign_id, parent_id, section_id, title, description, assignee_id, due_date, status, position) values ('109064fb-b7ee-5b31-ba87-a03aa6261bea', '3b62c326-1bb6-50f5-afff-5e998d9b079d', null, 'e96cb13d-170c-5103-a2bf-dffc9dea1dc0', 'Remove from rest of Whatsapp groups', 'Usually done by: Elisa Bedin', (select id from public.people where active and lower(name) = lower('Elisa Bedin') limit 1), null, 'todo', 8000) on conflict (id) do nothing;
insert into public.tasks (id, campaign_id, parent_id, section_id, title, description, assignee_id, due_date, status, position) values ('acf133f3-35b8-572f-b2e4-eb95b8520948', '3b62c326-1bb6-50f5-afff-5e998d9b079d', null, 'e96cb13d-170c-5103-a2bf-dffc9dea1dc0', 'Remove client from CDI list', 'Usually done by: Elisa Bedin

https://docs.google.com/spreadsheets/d/1vTylvyi-xp0Sf9tAE9zbEp73Hp5boWMjKAN6oKI4sXs/edit?gid=0#gid=0', (select id from public.people where active and lower(name) = lower('Elisa Bedin') limit 1), null, 'todo', 9000) on conflict (id) do nothing;
insert into public.tasks (id, campaign_id, parent_id, section_id, title, description, assignee_id, due_date, status, position) values ('2431a5a9-7c86-5572-adc7-cb44e8b92403', '3b62c326-1bb6-50f5-afff-5e998d9b079d', null, 'e96cb13d-170c-5103-a2bf-dffc9dea1dc0', 'Update spreadsheet', 'Usually done by: Elisa Bedin', (select id from public.people where active and lower(name) = lower('Elisa Bedin') limit 1), null, 'todo', 10000) on conflict (id) do nothing;
insert into public.tasks (id, campaign_id, parent_id, section_id, title, description, assignee_id, due_date, status, position) values ('940c903b-675e-519a-ac88-6f861968fc24', '3b62c326-1bb6-50f5-afff-5e998d9b079d', null, 'e96cb13d-170c-5103-a2bf-dffc9dea1dc0', 'Notify PC - Automate', 'Usually done by: John Coachman

Notify John, Ricardo, Mariana, Carlos, Isan, Angelo, Pablo', (select id from public.people where active and lower(name) = lower('John Coachman') limit 1), null, 'todo', 11000) on conflict (id) do nothing;
insert into public.tasks (id, campaign_id, parent_id, section_id, title, description, assignee_id, due_date, status, position) values ('56a87d33-2129-52c1-9ea4-77236aae36c3', '3b62c326-1bb6-50f5-afff-5e998d9b079d', null, 'e96cb13d-170c-5103-a2bf-dffc9dea1dc0', 'Fill Out Offboarding Asana Brain form', 'Usually done by: Elisa Bedin

Use Form - https://form.asana.com/?k=S9b-Onk_ok-O1P-bDc7nEQ&d=472634702533497', (select id from public.people where active and lower(name) = lower('Elisa Bedin') limit 1), null, 'todo', 12000) on conflict (id) do nothing;
insert into public.tasks (id, campaign_id, parent_id, section_id, title, description, assignee_id, due_date, status, position) values ('8aa42233-2290-55af-b4b2-dc90a669d3e3', '3b62c326-1bb6-50f5-afff-5e998d9b079d', null, 'e96cb13d-170c-5103-a2bf-dffc9dea1dc0', 'Remove Clinic Portal Access & Access to MKT Materials', '    Go to Entries → Online Courses:
        Search for clinic.
        Click Disable in top right.
    Under Digital Products → Licenses:
        Search by clinic name.
        Disable all licenses associated.', null, null, 'todo', 13000) on conflict (id) do nothing;
insert into public.tasks (id, campaign_id, parent_id, section_id, title, description, assignee_id, due_date, status, position) values ('3849fce4-50ef-58d1-8bdf-a1d51bb18192', '3b62c326-1bb6-50f5-afff-5e998d9b079d', null, 'c6dbfb87-96a7-5622-bbf9-be93daab2267', 'Remove from BeDSD+', 'Usually done by: Daisy Mason', (select id from public.people where active and lower(name) = lower('Daisy Mason') limit 1), null, 'todo', 14000) on conflict (id) do nothing;
insert into public.tasks (id, campaign_id, parent_id, section_id, title, description, assignee_id, due_date, status, position) values ('93e1487b-fc7c-5a93-843a-4f46e40fe83b', '3b62c326-1bb6-50f5-afff-5e998d9b079d', null, 'c6dbfb87-96a7-5622-bbf9-be93daab2267', 'Remove clinic from DSD clinics network', 'Usually done by: Elisa Bedin

How to do it : https://scribehow.com/viewer/How_to_Disable_a_DSD_Clinic_Network_Entry__JjGQFC6xRMKr9JkCW-kv2g', (select id from public.people where active and lower(name) = lower('Elisa Bedin') limit 1), null, 'todo', 15000) on conflict (id) do nothing;
insert into public.tasks (id, campaign_id, parent_id, section_id, title, description, assignee_id, due_date, status, position) values ('cd9599fd-766b-551c-b710-89e61ed54620', '3b62c326-1bb6-50f5-afff-5e998d9b079d', null, 'c6dbfb87-96a7-5622-bbf9-be93daab2267', 'Remove from find a DSD clinic page', 'Usually done by: Elisa Bedin

How to do it : https://scribehow.com/viewer/Unpublish_Clinic_page__5UszwtpdTlmJrQ1m4Yi0sQ', (select id from public.people where active and lower(name) = lower('Elisa Bedin') limit 1), null, 'todo', 16000) on conflict (id) do nothing;
insert into public.tasks (id, campaign_id, parent_id, section_id, title, description, assignee_id, due_date, status, position) values ('1d8a4825-bcba-501f-a46c-7bab875f2554', '3b62c326-1bb6-50f5-afff-5e998d9b079d', null, 'c6dbfb87-96a7-5622-bbf9-be93daab2267', 'Stop Paid Media Funnels', 'Usually done by: Elisa Bedin', (select id from public.people where active and lower(name) = lower('Elisa Bedin') limit 1), null, 'todo', 17000) on conflict (id) do nothing;

-- Team Consultancy preparation (DCCP)
insert into public.campaigns (id, name, description, department_id, for_department_id, status, start_date, end_date, owner_id, planned_hours, private, is_template)
values ('e4021a13-b7f8-5e00-9034-715db19030af', 'Team Consultancy preparation (DCCP)', 'Preparing a DSD Team Consultancy for a DCCP client, from the new patient entering the workflow to post-consultancy. Name the project “Consultancy preparation for [Dr Name] - DCCP Client - Order: [order]”. Set the start date to 6 weeks before the consultancy: every task date follows. The “Timing” field says when each task happens.', public.department_id_for('delight'), public.department_id_for('delight'), 'planned', '2026-10-31', '2027-01-11', (select id from public.people where lower(email) like 'csolla@%' limit 1), 0, false, true)
on conflict (id) do nothing;
insert into public.sections (id, campaign_id, name, position) values ('516151d0-8d5d-57c3-a024-f42c4baf0f48', 'e4021a13-b7f8-5e00-9034-715db19030af', 'New patient enters workflow', 1000) on conflict (id) do nothing;
insert into public.sections (id, campaign_id, name, position) values ('b1905261-9afb-5ee5-8e04-b8d3049a612d', 'e4021a13-b7f8-5e00-9034-715db19030af', 'Consultancy preparation', 2000) on conflict (id) do nothing;
insert into public.sections (id, campaign_id, name, position) values ('66e0d8f7-4472-5bbc-a389-df8731cc84f7', 'e4021a13-b7f8-5e00-9034-715db19030af', 'PC Stage', 3000) on conflict (id) do nothing;
insert into public.sections (id, campaign_id, name, position) values ('deec400d-aba6-5003-89e2-c11f645e09a8', 'e4021a13-b7f8-5e00-9034-715db19030af', 'Lab Stage', 4000) on conflict (id) do nothing;
insert into public.sections (id, campaign_id, name, position) values ('36610dcc-44f1-57a3-ab27-39ca8ade446d', 'e4021a13-b7f8-5e00-9034-715db19030af', 'Post-Consultancy', 5000) on conflict (id) do nothing;
insert into public.custom_fields (id, campaign_id, name, type, settings, position) values ('6da900fc-7bc1-52b0-a672-81a06575f91a', 'e4021a13-b7f8-5e00-9034-715db19030af', 'Who', 'text', '{}'::jsonb, 1000) on conflict (id) do nothing;
insert into public.custom_fields (id, campaign_id, name, type, settings, position) values ('a490d14e-39b0-5eb2-86a9-262bf0a9475e', 'e4021a13-b7f8-5e00-9034-715db19030af', 'Timing', 'text', '{}'::jsonb, 2000) on conflict (id) do nothing;
insert into public.custom_fields (id, campaign_id, name, type, settings, position) values ('af6e28ed-2d44-5a11-b798-bd02d3e58736', 'e4021a13-b7f8-5e00-9034-715db19030af', 'NPS score', 'number', '{}'::jsonb, 3000) on conflict (id) do nothing;
insert into public.tasks (id, campaign_id, parent_id, section_id, title, description, assignee_id, due_date, status, position) values ('af1f7731-0a86-5c9d-8f71-3dd47814216f', 'e4021a13-b7f8-5e00-9034-715db19030af', null, '516151d0-8d5d-57c3-a024-f42c4baf0f48', 'Create Consultancy PC products order', 'Usually done by: Ricardo Serrano Majano

    Diagnostic Design + CAA pack
    Motivational Mock-up Manufacture
    DSD Shell Design 
    DSD Shell Manufacture', (select id from public.people where active and lower(name) = lower('Ricardo Serrano Majano') limit 1), '2026-10-31', 'todo', 1000) on conflict (id) do nothing;
insert into public.task_field_values (task_id, field_id, campaign_id, value) values ('af1f7731-0a86-5c9d-8f71-3dd47814216f', '6da900fc-7bc1-52b0-a672-81a06575f91a', 'e4021a13-b7f8-5e00-9034-715db19030af', '"CS"'::jsonb) on conflict (task_id, field_id) do nothing;
insert into public.task_field_values (task_id, field_id, campaign_id, value) values ('af1f7731-0a86-5c9d-8f71-3dd47814216f', 'a490d14e-39b0-5eb2-86a9-262bf0a9475e', 'e4021a13-b7f8-5e00-9034-715db19030af', '"6 weeks prior consultancy"'::jsonb) on conflict (task_id, field_id) do nothing;
insert into public.tasks (id, campaign_id, parent_id, section_id, title, description, assignee_id, due_date, status, position) values ('5500361e-9b17-5998-b0c2-22e3c141f1ca', 'e4021a13-b7f8-5e00-9034-715db19030af', null, '516151d0-8d5d-57c3-a024-f42c4baf0f48', 'Patient Activated in Vevi', 'Usually done by: Ricardo Serrano Majano', (select id from public.people where active and lower(name) = lower('Ricardo Serrano Majano') limit 1), '2026-11-02', 'todo', 2000) on conflict (id) do nothing;
insert into public.task_field_values (task_id, field_id, campaign_id, value) values ('5500361e-9b17-5998-b0c2-22e3c141f1ca', '6da900fc-7bc1-52b0-a672-81a06575f91a', 'e4021a13-b7f8-5e00-9034-715db19030af', '"CS"'::jsonb) on conflict (task_id, field_id) do nothing;
insert into public.task_field_values (task_id, field_id, campaign_id, value) values ('5500361e-9b17-5998-b0c2-22e3c141f1ca', 'a490d14e-39b0-5eb2-86a9-262bf0a9475e', 'e4021a13-b7f8-5e00-9034-715db19030af', '"2 days after previous"'::jsonb) on conflict (task_id, field_id) do nothing;
insert into public.tasks (id, campaign_id, parent_id, section_id, title, description, assignee_id, due_date, status, position) values ('23f03631-814f-5aa8-8e53-8dbc69b71c8c', 'e4021a13-b7f8-5e00-9034-715db19030af', null, '516151d0-8d5d-57c3-a024-f42c4baf0f48', 'Add extra time of PC access if needed (until consultancy date)', 'Usually done by: Ricardo Serrano Majano', (select id from public.people where active and lower(name) = lower('Ricardo Serrano Majano') limit 1), '2026-11-02', 'todo', 3000) on conflict (id) do nothing;
insert into public.tasks (id, campaign_id, parent_id, section_id, title, description, assignee_id, due_date, status, position) values ('7eb9e587-d76c-5c4a-bf31-c6e461acec01', 'e4021a13-b7f8-5e00-9034-715db19030af', null, 'b1905261-9afb-5ee5-8e04-b8d3049a612d', 'Confirm patient selected and files uploaded to PC', 'Usually done by: Lindi Rigo', (select id from public.people where active and lower(name) = lower('Lindi Rigo') limit 1), '2026-10-31', 'todo', 4000) on conflict (id) do nothing;
insert into public.task_field_values (task_id, field_id, campaign_id, value) values ('7eb9e587-d76c-5c4a-bf31-c6e461acec01', '6da900fc-7bc1-52b0-a672-81a06575f91a', 'e4021a13-b7f8-5e00-9034-715db19030af', '"Consultant"'::jsonb) on conflict (task_id, field_id) do nothing;
insert into public.task_field_values (task_id, field_id, campaign_id, value) values ('7eb9e587-d76c-5c4a-bf31-c6e461acec01', 'a490d14e-39b0-5eb2-86a9-262bf0a9475e', 'e4021a13-b7f8-5e00-9034-715db19030af', '"6 weeks before consultant"'::jsonb) on conflict (task_id, field_id) do nothing;
insert into public.tasks (id, campaign_id, parent_id, section_id, title, description, assignee_id, due_date, status, position) values ('acbd3f0a-5bfa-531a-b1f5-2d5166667b30', 'e4021a13-b7f8-5e00-9034-715db19030af', null, 'b1905261-9afb-5ee5-8e04-b8d3049a612d', 'Check in chat/web if files are good and product was added to case', 'Usually done by: Lindi Rigo', (select id from public.people where active and lower(name) = lower('Lindi Rigo') limit 1), '2026-11-02', 'todo', 5000) on conflict (id) do nothing;
insert into public.task_field_values (task_id, field_id, campaign_id, value) values ('acbd3f0a-5bfa-531a-b1f5-2d5166667b30', '6da900fc-7bc1-52b0-a672-81a06575f91a', 'e4021a13-b7f8-5e00-9034-715db19030af', '"Consultant"'::jsonb) on conflict (task_id, field_id) do nothing;
insert into public.task_field_values (task_id, field_id, campaign_id, value) values ('acbd3f0a-5bfa-531a-b1f5-2d5166667b30', 'a490d14e-39b0-5eb2-86a9-262bf0a9475e', 'e4021a13-b7f8-5e00-9034-715db19030af', '"2 days after previous"'::jsonb) on conflict (task_id, field_id) do nothing;
insert into public.tasks (id, campaign_id, parent_id, section_id, title, description, assignee_id, due_date, status, position) values ('dc68b8ea-507c-599b-9b7e-aaf058566aa3', 'e4021a13-b7f8-5e00-9034-715db19030af', null, 'b1905261-9afb-5ee5-8e04-b8d3049a612d', 'Book CAA call and make sure attends the call', 'Usually done by: Lindi Rigo', (select id from public.people where active and lower(name) = lower('Lindi Rigo') limit 1), '2026-11-14', 'todo', 6000) on conflict (id) do nothing;
insert into public.task_field_values (task_id, field_id, campaign_id, value) values ('dc68b8ea-507c-599b-9b7e-aaf058566aa3', '6da900fc-7bc1-52b0-a672-81a06575f91a', 'e4021a13-b7f8-5e00-9034-715db19030af', '"Consultant"'::jsonb) on conflict (task_id, field_id) do nothing;
insert into public.task_field_values (task_id, field_id, campaign_id, value) values ('dc68b8ea-507c-599b-9b7e-aaf058566aa3', 'a490d14e-39b0-5eb2-86a9-262bf0a9475e', 'e4021a13-b7f8-5e00-9034-715db19030af', '"4 weeks"'::jsonb) on conflict (task_id, field_id) do nothing;
insert into public.tasks (id, campaign_id, parent_id, section_id, title, description, assignee_id, due_date, status, position) values ('da4596a3-a46d-5beb-8ff4-1f403e975bbf', 'e4021a13-b7f8-5e00-9034-715db19030af', null, 'b1905261-9afb-5ee5-8e04-b8d3049a612d', 'Check if design is ready, approved, and ready for manufacture by DSD Lab', 'Usually done by: Lindi Rigo', (select id from public.people where active and lower(name) = lower('Lindi Rigo') limit 1), '2026-11-21', 'todo', 7000) on conflict (id) do nothing;
insert into public.task_field_values (task_id, field_id, campaign_id, value) values ('da4596a3-a46d-5beb-8ff4-1f403e975bbf', '6da900fc-7bc1-52b0-a672-81a06575f91a', 'e4021a13-b7f8-5e00-9034-715db19030af', '"Consultant"'::jsonb) on conflict (task_id, field_id) do nothing;
insert into public.task_field_values (task_id, field_id, campaign_id, value) values ('da4596a3-a46d-5beb-8ff4-1f403e975bbf', 'a490d14e-39b0-5eb2-86a9-262bf0a9475e', 'e4021a13-b7f8-5e00-9034-715db19030af', '"3 weeks prior consultancy"'::jsonb) on conflict (task_id, field_id) do nothing;
insert into public.tasks (id, campaign_id, parent_id, section_id, title, description, assignee_id, due_date, status, position) values ('8c07ea36-f697-5ab2-bb95-3f77bc5e7f8a', 'e4021a13-b7f8-5e00-9034-715db19030af', null, 'b1905261-9afb-5ee5-8e04-b8d3049a612d', 'Case shipped to the clinic and arrived', 'Usually done by: Lindi Rigo', (select id from public.people where active and lower(name) = lower('Lindi Rigo') limit 1), '2026-12-05', 'todo', 8000) on conflict (id) do nothing;
insert into public.task_field_values (task_id, field_id, campaign_id, value) values ('8c07ea36-f697-5ab2-bb95-3f77bc5e7f8a', '6da900fc-7bc1-52b0-a672-81a06575f91a', 'e4021a13-b7f8-5e00-9034-715db19030af', '"Consultant"'::jsonb) on conflict (task_id, field_id) do nothing;
insert into public.task_field_values (task_id, field_id, campaign_id, value) values ('8c07ea36-f697-5ab2-bb95-3f77bc5e7f8a', 'a490d14e-39b0-5eb2-86a9-262bf0a9475e', 'e4021a13-b7f8-5e00-9034-715db19030af', '"1 week prior consultancy"'::jsonb) on conflict (task_id, field_id) do nothing;
insert into public.tasks (id, campaign_id, parent_id, section_id, title, description, assignee_id, due_date, status, position) values ('4cf5f0df-3a0a-557b-8fe7-bcfaaa7ccbe6', 'e4021a13-b7f8-5e00-9034-715db19030af', null, 'b1905261-9afb-5ee5-8e04-b8d3049a612d', 'Phone call with Dr', 'Usually done by: Lindi Rigo', (select id from public.people where active and lower(name) = lower('Lindi Rigo') limit 1), '2026-12-05', 'todo', 9000) on conflict (id) do nothing;
insert into public.task_field_values (task_id, field_id, campaign_id, value) values ('4cf5f0df-3a0a-557b-8fe7-bcfaaa7ccbe6', '6da900fc-7bc1-52b0-a672-81a06575f91a', 'e4021a13-b7f8-5e00-9034-715db19030af', '"Consultant"'::jsonb) on conflict (task_id, field_id) do nothing;
insert into public.task_field_values (task_id, field_id, campaign_id, value) values ('4cf5f0df-3a0a-557b-8fe7-bcfaaa7ccbe6', 'a490d14e-39b0-5eb2-86a9-262bf0a9475e', 'e4021a13-b7f8-5e00-9034-715db19030af', '"1 week prior consultancy"'::jsonb) on conflict (task_id, field_id) do nothing;
insert into public.tasks (id, campaign_id, parent_id, section_id, title, description, assignee_id, due_date, status, position) values ('465b1a44-f79c-5dcd-bede-e6db5f49cdfd', 'e4021a13-b7f8-5e00-9034-715db19030af', null, 'b1905261-9afb-5ee5-8e04-b8d3049a612d', 'Consultancy delivery', 'Usually done by: Lindi Rigo', (select id from public.people where active and lower(name) = lower('Lindi Rigo') limit 1), '2026-12-12', 'todo', 10000) on conflict (id) do nothing;
insert into public.task_field_values (task_id, field_id, campaign_id, value) values ('465b1a44-f79c-5dcd-bede-e6db5f49cdfd', '6da900fc-7bc1-52b0-a672-81a06575f91a', 'e4021a13-b7f8-5e00-9034-715db19030af', '"Consultant"'::jsonb) on conflict (task_id, field_id) do nothing;
insert into public.task_field_values (task_id, field_id, campaign_id, value) values ('465b1a44-f79c-5dcd-bede-e6db5f49cdfd', 'a490d14e-39b0-5eb2-86a9-262bf0a9475e', 'e4021a13-b7f8-5e00-9034-715db19030af', '"First day of Consultancy"'::jsonb) on conflict (task_id, field_id) do nothing;
insert into public.tasks (id, campaign_id, parent_id, section_id, title, description, assignee_id, due_date, status, position) values ('35d236e7-52d2-5b90-8e0b-c82fee020aa3', 'e4021a13-b7f8-5e00-9034-715db19030af', null, '66e0d8f7-4472-5bbc-a389-df8731cc84f7', 'Diagnostic Design Planning Started', 'Usually done by: Ricardo Serrano Majano', (select id from public.people where active and lower(name) = lower('Ricardo Serrano Majano') limit 1), '2026-11-07', 'todo', 11000) on conflict (id) do nothing;
insert into public.task_field_values (task_id, field_id, campaign_id, value) values ('35d236e7-52d2-5b90-8e0b-c82fee020aa3', '6da900fc-7bc1-52b0-a672-81a06575f91a', 'e4021a13-b7f8-5e00-9034-715db19030af', '"Interdisciplinary"'::jsonb) on conflict (task_id, field_id) do nothing;
insert into public.task_field_values (task_id, field_id, campaign_id, value) values ('35d236e7-52d2-5b90-8e0b-c82fee020aa3', 'a490d14e-39b0-5eb2-86a9-262bf0a9475e', 'e4021a13-b7f8-5e00-9034-715db19030af', '"5 weeks prior consultancy"'::jsonb) on conflict (task_id, field_id) do nothing;
insert into public.tasks (id, campaign_id, parent_id, section_id, title, description, assignee_id, due_date, status, position) values ('d5005529-afdf-5c2a-a9fd-57863dbded4d', 'e4021a13-b7f8-5e00-9034-715db19030af', null, '66e0d8f7-4472-5bbc-a389-df8731cc84f7', 'CAA Call ideal', 'Usually done by: Ricardo Serrano Majano', (select id from public.people where active and lower(name) = lower('Ricardo Serrano Majano') limit 1), '2026-11-14', 'todo', 12000) on conflict (id) do nothing;
insert into public.task_field_values (task_id, field_id, campaign_id, value) values ('d5005529-afdf-5c2a-a9fd-57863dbded4d', '6da900fc-7bc1-52b0-a672-81a06575f91a', 'e4021a13-b7f8-5e00-9034-715db19030af', '"Francis / Tati / Daniel"'::jsonb) on conflict (task_id, field_id) do nothing;
insert into public.task_field_values (task_id, field_id, campaign_id, value) values ('d5005529-afdf-5c2a-a9fd-57863dbded4d', 'a490d14e-39b0-5eb2-86a9-262bf0a9475e', 'e4021a13-b7f8-5e00-9034-715db19030af', '"4 weeks prior consultancy"'::jsonb) on conflict (task_id, field_id) do nothing;
insert into public.tasks (id, campaign_id, parent_id, section_id, title, description, assignee_id, due_date, status, position) values ('65f9d619-643a-5c84-b555-49528f07a4e9', 'e4021a13-b7f8-5e00-9034-715db19030af', null, '66e0d8f7-4472-5bbc-a389-df8731cc84f7', 'Diagnostic Design Planning Deadline', 'Usually done by: Ricardo Serrano Majano', (select id from public.people where active and lower(name) = lower('Ricardo Serrano Majano') limit 1), '2026-11-21', 'todo', 13000) on conflict (id) do nothing;
insert into public.task_field_values (task_id, field_id, campaign_id, value) values ('65f9d619-643a-5c84-b555-49528f07a4e9', '6da900fc-7bc1-52b0-a672-81a06575f91a', 'e4021a13-b7f8-5e00-9034-715db19030af', '"Interdisciplinary"'::jsonb) on conflict (task_id, field_id) do nothing;
insert into public.task_field_values (task_id, field_id, campaign_id, value) values ('65f9d619-643a-5c84-b555-49528f07a4e9', 'a490d14e-39b0-5eb2-86a9-262bf0a9475e', 'e4021a13-b7f8-5e00-9034-715db19030af', '"3 weeks prior consultancy"'::jsonb) on conflict (task_id, field_id) do nothing;
insert into public.tasks (id, campaign_id, parent_id, section_id, title, description, assignee_id, due_date, status, position) values ('48abb309-ec4d-5b10-93ac-58057789c79b', 'e4021a13-b7f8-5e00-9034-715db19030af', null, '66e0d8f7-4472-5bbc-a389-df8731cc84f7', 'Final PC report + CAA slides uploaded', 'Usually done by: Ricardo Serrano Majano', (select id from public.people where active and lower(name) = lower('Ricardo Serrano Majano') limit 1), '2026-12-05', 'todo', 14000) on conflict (id) do nothing;
insert into public.task_field_values (task_id, field_id, campaign_id, value) values ('48abb309-ec4d-5b10-93ac-58057789c79b', '6da900fc-7bc1-52b0-a672-81a06575f91a', 'e4021a13-b7f8-5e00-9034-715db19030af', '"CS"'::jsonb) on conflict (task_id, field_id) do nothing;
insert into public.task_field_values (task_id, field_id, campaign_id, value) values ('48abb309-ec4d-5b10-93ac-58057789c79b', 'a490d14e-39b0-5eb2-86a9-262bf0a9475e', 'e4021a13-b7f8-5e00-9034-715db19030af', '"1 week prior consultancy"'::jsonb) on conflict (task_id, field_id) do nothing;
insert into public.tasks (id, campaign_id, parent_id, section_id, title, description, assignee_id, due_date, status, position) values ('887f9af2-bd56-508f-8f9b-ea2064159d84', 'e4021a13-b7f8-5e00-9034-715db19030af', null, 'deec400d-aba6-5003-89e2-c11f645e09a8', 'Motivational Mock-up & Shell Manufactured and shipped', 'Usually done by: Ricardo Serrano Majano', (select id from public.people where active and lower(name) = lower('Ricardo Serrano Majano') limit 1), '2026-11-28', 'todo', 15000) on conflict (id) do nothing;
insert into public.task_field_values (task_id, field_id, campaign_id, value) values ('887f9af2-bd56-508f-8f9b-ea2064159d84', '6da900fc-7bc1-52b0-a672-81a06575f91a', 'e4021a13-b7f8-5e00-9034-715db19030af', '"Lab"'::jsonb) on conflict (task_id, field_id) do nothing;
insert into public.task_field_values (task_id, field_id, campaign_id, value) values ('887f9af2-bd56-508f-8f9b-ea2064159d84', 'a490d14e-39b0-5eb2-86a9-262bf0a9475e', 'e4021a13-b7f8-5e00-9034-715db19030af', '"2 weeks prior consultancy"'::jsonb) on conflict (task_id, field_id) do nothing;
insert into public.tasks (id, campaign_id, parent_id, section_id, title, description, assignee_id, due_date, status, position) values ('018d6cb6-2432-5282-901e-8871e965e9e2', 'e4021a13-b7f8-5e00-9034-715db19030af', null, '36610dcc-44f1-57a3-ab27-39ca8ade446d', 'Write Consultancy recap', 'Usually done by: Lindi Rigo', (select id from public.people where active and lower(name) = lower('Lindi Rigo') limit 1), '2026-12-15', 'todo', 16000) on conflict (id) do nothing;
insert into public.task_field_values (task_id, field_id, campaign_id, value) values ('018d6cb6-2432-5282-901e-8871e965e9e2', '6da900fc-7bc1-52b0-a672-81a06575f91a', 'e4021a13-b7f8-5e00-9034-715db19030af', '"Consultant"'::jsonb) on conflict (task_id, field_id) do nothing;
insert into public.task_field_values (task_id, field_id, campaign_id, value) values ('018d6cb6-2432-5282-901e-8871e965e9e2', 'a490d14e-39b0-5eb2-86a9-262bf0a9475e', 'e4021a13-b7f8-5e00-9034-715db19030af', '"3 days after the Consutancy"'::jsonb) on conflict (task_id, field_id) do nothing;
insert into public.tasks (id, campaign_id, parent_id, section_id, title, description, assignee_id, due_date, status, position) values ('53b401b2-449d-5c01-9faa-36e557b9a3cb', 'e4021a13-b7f8-5e00-9034-715db19030af', null, '36610dcc-44f1-57a3-ab27-39ca8ade446d', 'Create audit report, deliver it to the doctor, and upload to Hubspot', 'Usually done by: Lindi Rigo', (select id from public.people where active and lower(name) = lower('Lindi Rigo') limit 1), '2027-01-11', 'todo', 17000) on conflict (id) do nothing;
insert into public.task_field_values (task_id, field_id, campaign_id, value) values ('53b401b2-449d-5c01-9faa-36e557b9a3cb', '6da900fc-7bc1-52b0-a672-81a06575f91a', 'e4021a13-b7f8-5e00-9034-715db19030af', '"Consultant"'::jsonb) on conflict (task_id, field_id) do nothing;
insert into public.task_field_values (task_id, field_id, campaign_id, value) values ('53b401b2-449d-5c01-9faa-36e557b9a3cb', 'a490d14e-39b0-5eb2-86a9-262bf0a9475e', 'e4021a13-b7f8-5e00-9034-715db19030af', '"30 days after the Consutlancy"'::jsonb) on conflict (task_id, field_id) do nothing;
insert into public.tasks (id, campaign_id, parent_id, section_id, title, description, assignee_id, due_date, status, position) values ('67deb1a7-632f-59e8-8415-8aa85e0b72c4', 'e4021a13-b7f8-5e00-9034-715db19030af', null, '36610dcc-44f1-57a3-ab27-39ca8ade446d', 'Check in Consultancy delivered - invoice', 'Usually done by: Lindi Rigo', (select id from public.people where active and lower(name) = lower('Lindi Rigo') limit 1), '2026-12-15', 'todo', 18000) on conflict (id) do nothing;
insert into public.tasks (id, campaign_id, parent_id, section_id, title, description, assignee_id, due_date, status, position) values ('2f3153f2-92f6-5936-b89d-c0555e3b65e8', 'e4021a13-b7f8-5e00-9034-715db19030af', null, '36610dcc-44f1-57a3-ab27-39ca8ade446d', 'NPS score', 'Usually done by: Lindi Rigo', (select id from public.people where active and lower(name) = lower('Lindi Rigo') limit 1), '2027-01-12', 'todo', 19000) on conflict (id) do nothing;

-- Job Scorecard
insert into public.campaigns (id, name, description, department_id, for_department_id, status, start_date, end_date, owner_id, planned_hours, private, is_template)
values ('1e1cc965-cb03-5863-99d3-951e50db10ba', 'Job Scorecard', 'Name:
Position & Who I Report To:
Purpose of the Role:


Useful resources:
    https://docs.google.com/document/d/1NjNK1Y_3EspHFEMJ-ZF9pNUnsO7hlCgWWJil1Lr94QA/edit?tab=t.0#heading=h.wxfeacsnih7a
    https://docs.google.com/document/d/1GLcG7FF9eTwfp3bm5BKr3EYyvGzGYCnYDlpp_k_09l8/edit?tab=t.0
    https://docs.google.com/document/d/1P0ddaCuMtiPNA1UQQq7KscOPaLaDupkOApQTHnn3Kvc/edit#heading=h.1sh67w8rgi3
    https://www.notion.so/digitalsmiledesign/DSD-Career-Framework-c424583fc5bf4d10b5c7f17d9d70ccf0

Name the project “[Team] [Employee name] Job Scorecard [Year]”, set the start date to 1 January, and add the employee and their manager under Who can see it.', public.department_id_for('corporate'), public.department_id_for('corporate'), 'planned', '2025-01-01', '2025-12-31', (select id from public.people where lower(email) like 'csolla@%' limit 1), 0, true, true)
on conflict (id) do nothing;
insert into public.sections (id, campaign_id, name, position) values ('0c2828f7-f661-5053-8a4a-80195ed40580', '1e1cc965-cb03-5863-99d3-951e50db10ba', 'Job Scorecard 1:1 Meetings', 1000) on conflict (id) do nothing;
insert into public.sections (id, campaign_id, name, position) values ('38ea9add-3f83-5e6d-a102-041855b985ec', '1e1cc965-cb03-5863-99d3-951e50db10ba', 'Role Responsibilities (RRs)', 2000) on conflict (id) do nothing;
insert into public.sections (id, campaign_id, name, position) values ('e7c964e8-da1b-5c83-abfb-77b3ae6e01c7', '1e1cc965-cb03-5863-99d3-951e50db10ba', 'Goals', 3000) on conflict (id) do nothing;
insert into public.sections (id, campaign_id, name, position) values ('d77428b9-c367-50ab-a255-b6de61ecec45', '1e1cc965-cb03-5863-99d3-951e50db10ba', 'Core Competencies (CCs)', 4000) on conflict (id) do nothing;
insert into public.sections (id, campaign_id, name, position) values ('4a691ab4-cfad-5cf1-ac0f-c33c69b0d784', '1e1cc965-cb03-5863-99d3-951e50db10ba', 'Other Discussions', 5000) on conflict (id) do nothing;
insert into public.custom_fields (id, campaign_id, name, type, settings, position) values ('77752f2d-7626-5a1e-9e61-c726c01536a9', '1e1cc965-cb03-5863-99d3-951e50db10ba', 'Goal Progress', 'number', '{}'::jsonb, 1000) on conflict (id) do nothing;
insert into public.custom_fields (id, campaign_id, name, type, settings, position) values ('ce47c81f-5cff-5158-9dca-589ed2413fb3', '1e1cc965-cb03-5863-99d3-951e50db10ba', 'Grade', 'choice', '{"options": ["Grade 1", "Grade 2", "Grade 3", "Grade 4"]}'::jsonb, 2000) on conflict (id) do nothing;
insert into public.custom_fields (id, campaign_id, name, type, settings, position) values ('56570e96-7d23-5d21-af7d-a9dbe081e0a5', '1e1cc965-cb03-5863-99d3-951e50db10ba', 'Goal Status', 'choice', '{"options": ["On track", "At risk", "Off track", "Achieved", "Partial", "Missed", "Dropped"]}'::jsonb, 3000) on conflict (id) do nothing;
insert into public.custom_fields (id, campaign_id, name, type, settings, position) values ('5ed526e1-1bc1-5874-9299-93d87facbd60', '1e1cc965-cb03-5863-99d3-951e50db10ba', 'H1 Ratings', 'number', '{}'::jsonb, 4000) on conflict (id) do nothing;
insert into public.custom_fields (id, campaign_id, name, type, settings, position) values ('532491d6-4d80-5cf2-b707-641ea7aceef1', '1e1cc965-cb03-5863-99d3-951e50db10ba', 'H2 Ratings', 'number', '{}'::jsonb, 5000) on conflict (id) do nothing;
insert into public.tasks (id, campaign_id, parent_id, section_id, title, description, assignee_id, due_date, status, position) values ('fa93b623-0ff3-5cd7-bf6d-633088845428', '1e1cc965-cb03-5863-99d3-951e50db10ba', null, '0c2828f7-f661-5053-8a4a-80195ed40580', 'Initiate the Job Scorecard', '    Goals definition
        Goal setting agreement
        Agree on how individual goals are going to be rated (what does it mean to be at 25%, 50%, etc.)

    Confirm Role Responsibilities', null, '2025-02-14', 'todo', 1000) on conflict (id) do nothing;
insert into public.tasks (id, campaign_id, parent_id, section_id, title, description, assignee_id, due_date, status, position) values ('68feb414-9e58-5a38-9836-f5c6f7fa55fd', '1e1cc965-cb03-5863-99d3-951e50db10ba', null, '0c2828f7-f661-5053-8a4a-80195ed40580', 'H1: Feb–Jun [Mid-year evaluation]', 'Meeting purpose: Rating and revisiting goals and responsibilities, and initiating discussions for potential level and step advancements.

    “Goal”- Rating review
    Role Responsibilities - Rating Review
    Core Competencies - Rating Review
        Self-assessment
        360 evaluation (for grades 3 and 4)
    Set expectations for the next Level & Step Gameplan:  Introducing the ''Next Level & Step Scorecard'' to track progress towards the next desired level.
         “Stretch Goal“ set for H2
        Role Responsibilities: Documented and defined for Next Level & Step', null, '2025-07-21', 'todo', 2000) on conflict (id) do nothing;
insert into public.tasks (id, campaign_id, parent_id, section_id, title, description, assignee_id, due_date, status, position) values ('baabe183-72e0-5e33-8fc5-efbfd6d17f68', '1e1cc965-cb03-5863-99d3-951e50db10ba', null, '0c2828f7-f661-5053-8a4a-80195ed40580', 'H2: Aug–Dec [End-of-year evaluation]', '    Current Job Level Scorecard
        “Goal” - Rating Review
        Role Responsibilities - Rating Review
    Next Job Level Job Scorecard track
        “Stretch Goal” Review
        Role Responsibilities - Rating Review
    Core Competencies - Rating Review', null, '2026-01-13', 'todo', 3000) on conflict (id) do nothing;
insert into public.tasks (id, campaign_id, parent_id, section_id, title, description, assignee_id, due_date, status, position) values ('c8eb1441-4c60-57f8-855e-c06670aacb11', '1e1cc965-cb03-5863-99d3-951e50db10ba', null, '0c2828f7-f661-5053-8a4a-80195ed40580', 'Manager to submit the employee development request for next year', 'Managers will submit the https://form.asana.com/?k=2Mp-HmHm4S3xKFB_aH5-7w&d=472634702533497 form if the employee is eligible for a review (A player).', null, '2026-01-20', 'todo', 4000) on conflict (id) do nothing;
insert into public.tasks (id, campaign_id, parent_id, section_id, title, description, assignee_id, due_date, status, position) values ('b411f737-9c93-506b-b05d-d20190c5fee6', '1e1cc965-cb03-5863-99d3-951e50db10ba', null, '38ea9add-3f83-5e6d-a102-041855b985ec', 'Role responsibility 1', null, null, null, 'todo', 5000) on conflict (id) do nothing;
insert into public.tasks (id, campaign_id, parent_id, section_id, title, description, assignee_id, due_date, status, position) values ('cadbe42d-77a7-5e38-801b-8e9ddbf561fe', '1e1cc965-cb03-5863-99d3-951e50db10ba', null, '38ea9add-3f83-5e6d-a102-041855b985ec', 'Role responsibility 2', null, null, null, 'todo', 6000) on conflict (id) do nothing;
insert into public.tasks (id, campaign_id, parent_id, section_id, title, description, assignee_id, due_date, status, position) values ('52d0d4bf-79b5-5113-98fb-514f535e9b9f', '1e1cc965-cb03-5863-99d3-951e50db10ba', null, 'e7c964e8-da1b-5c83-abfb-77b3ae6e01c7', 'Individual goal 1', null, null, null, 'todo', 7000) on conflict (id) do nothing;
insert into public.tasks (id, campaign_id, parent_id, section_id, title, description, assignee_id, due_date, status, position) values ('29eac541-32e9-5cfb-a80f-114f21d4d8c2', '1e1cc965-cb03-5863-99d3-951e50db10ba', null, 'e7c964e8-da1b-5c83-abfb-77b3ae6e01c7', 'Individual goal 2', null, null, null, 'todo', 8000) on conflict (id) do nothing;

commit;

-- Check: one row per template, with its counts
select c.name,
       (select count(*) from public.sections where campaign_id = c.id) as sections,
       (select count(*) from public.tasks where campaign_id = c.id and parent_id is null) as tasks,
       (select count(*) from public.tasks where campaign_id = c.id and parent_id is not null) as subtasks,
       (select count(*) from public.custom_fields where campaign_id = c.id) as fields
from public.campaigns c where c.is_template order by c.name;
