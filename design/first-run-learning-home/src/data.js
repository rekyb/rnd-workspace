/* Sample data for the onboarding funnel and the first-run Learning Home.
 *
 * Shaped per design/onboarding-solve-edu/PRD.md §13 Data Model and the scoped
 * PRD §8 in this project. Nothing here is invented beyond that shape.
 *
 * The rule this file exists to enforce: every number the prototype renders
 * comes from here or is computed from here. No progress figure is written as a
 * literal in the markup, which is precisely the defect the legacy funnel
 * prototype carries (a hard-coded 1-day streak and a 150-point total).
 */

window.FRLH = {

  /* Step lists per entry path. Slice 10 requires the progress indicator to
     reflect the real configured step count and expose a text equivalent, so
     both the bar and the "Step N of M" string derive from these arrays and
     never from a hard-coded percentage map. The program path is shorter
     because a validated code already supplies the routing context that the
     goal step would otherwise collect. */
  steps: {
    organic: ['name', 'country', 'age', 'goal', 'account'],
    program: ['code', 'preview', 'name', 'country', 'age', 'account']
  },

  ageBands: [
    { value: '13-17', label: '13 to 17' },
    { value: '18-24', label: '18 to 24' },
    { value: '25-64', label: '25 or older' }
  ],

  goals: [
    { value: 'data', label: 'Data and analysis' },
    { value: 'service', label: 'Customer service' },
    { value: 'project', label: 'Project management' },
    { value: 'marketing', label: 'Digital marketing' },
    { value: 'comms', label: 'Communication' },
    { value: 'language', label: 'Language skills' }
  ],

  countries: [
    { value: 'ID', label: 'Indonesia' },
    { value: 'MY', label: 'Malaysia' },
    { value: 'PH', label: 'Philippines' },
    { value: 'SG', label: 'Singapore' },
    { value: 'TH', label: 'Thailand' },
    { value: 'VN', label: 'Viet Nam' }
  ],

  /* The goal-to-course map. PRD Slice 6 requires exactly one first course per
     goal, never a shortlist, because a first-run home has no basis on which to
     rank one. 'language' is deliberately absent, so the unmapped path is
     reachable by choosing Language skills rather than by a debug control. */
  courseMap: {
    data: { id: 'data-1', title: 'Reading a dataset', unit: 'First unit of Data and analysis', skills: 5 },
    service: { id: 'service-1', title: 'Answering a first ticket', unit: 'First unit of Customer service', skills: 4 },
    project: { id: 'project-1', title: 'Writing a project brief', unit: 'First unit of Project management', skills: 6 },
    marketing: { id: 'marketing-1', title: 'Writing a campaign brief', unit: 'First unit of Digital marketing', skills: 5 },
    comms: { id: 'comms-1', title: 'Structuring a short update', unit: 'First unit of Communication', skills: 4 }
  },

  /* A facilitator-issued code. Slice 3 requires the preview to resolve a real
     program identity and to name what the facilitator will be able to do,
     before the learner confirms. */
  programs: {
    SEDU24: {
      name: 'Digital Skills Cohort',
      organization: 'Community Learning Centre',
      facilitatorCapabilities: [
        'See which skills you have finished',
        'Assign work to you',
        'Remove you from this cohort'
      ],
      firstAction: { id: 'marketing-1', title: 'Writing a campaign brief', unit: 'First task in your program', skills: 4 },
      tasks: [
        { id: 't1', title: 'Writing a campaign brief' },
        { id: 't2', title: 'Choosing an audience' },
        { id: 't3', title: 'Setting a budget' },
        { id: 't4', title: 'Measuring a result' }
      ]
    }
  }
};
