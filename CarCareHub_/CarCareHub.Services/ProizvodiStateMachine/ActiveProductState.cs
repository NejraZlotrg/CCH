using AutoMapper;
using CarCareHub.Services.Database;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace CarCareHub.Services.ProizvodiStateMachine
{
    public class ActiveProductState : BaseState
    {
        public ActiveProductState(CchV2AliContext dbContext, IMapper mapper, IServiceProvider serviceProvider) : base(dbContext, mapper, serviceProvider)
        {
        }
        public override async Task<Model.Proizvod> Hide(int id)
        {
            var set = await _dbContext.Set<Database.Proizvod>().FindAsync(id);

            set.StateMachine = "draft";
            await _dbContext.SaveChangesAsync();

            return _mapper.Map<Model.Proizvod>(set);
        }
        public override async Task<List<string>> AllowedActions(int id)
        {
            var list = await base.AllowedActions(id);
            list.Add("hide");

            return list;
        }
    }
}