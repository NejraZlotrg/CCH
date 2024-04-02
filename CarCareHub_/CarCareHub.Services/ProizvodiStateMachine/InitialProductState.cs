
using AutoMapper;
using CarCareHub.Model;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace CarCareHub.Services.ProizvodiStateMachine
{
    public class InitialProductState : BaseState
    {
        public InitialProductState(Database.CchV2AliContext dbContext, IMapper mapper, IServiceProvider serviceProvider) : base(dbContext, mapper, serviceProvider)
        {
        }

        public override async Task<Proizvod> Insert(ProizvodiInsert insert)
        {
            var set = _dbContext.Set<Database.Proizvod>();

            var entity = _mapper.Map<Database.Proizvod>(insert);

            entity.StateMachine = "draft";
            set.Add(entity);

            await _dbContext.SaveChangesAsync();

            return _mapper.Map<Proizvod>(entity);

        }
        public override async Task<List<string>> AllowedActions(int id)
        {
            var list = await base.AllowedActions(id);
            list.Add("insert");

            return list;
        }
    }
}