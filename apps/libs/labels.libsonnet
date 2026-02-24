{
  local this = self,

  commonLabels(ctx): {
    "pluggi.fr/team": ctx.team,
    "pluggi.fr/budget": ctx.budget,
    svc: ctx.svc,
  },

  withCommonLabels(ctx): {
    metadata+: {
      labels+: this.commonLabels(ctx),
    },
  },
}
