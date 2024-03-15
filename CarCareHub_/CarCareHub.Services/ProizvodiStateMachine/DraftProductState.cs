using AutoMapper;
using CarCareHub.Model;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace CarCareHub.Services.ProizvodiStateMachine
{
    public class DraftProductState : BaseState
    {
        public DraftProductState(Database.CchV2AliContext dbContext, IMapper mapper, IServiceProvider serviceProvider) : base(dbContext, mapper, serviceProvider)
        {
        }

        public override async Task<Proizvod> Update(int id, ProizvodiUpdate insert)
        {
            var set = await _dbContext.Set<Database.Proizvod>().FindAsync(id);

            //   var entity = set.FindAsync(id);

            _mapper.Map(insert, set);

            await _dbContext.SaveChangesAsync();


            return _mapper.Map<Model.Proizvod>(set);
        }
        public override async Task<Proizvod> Activate(int id)
        {
            var set = await _dbContext.Set<Database.Proizvod>().FindAsync(id);

            set.StateMachine = "active";
            await _dbContext.SaveChangesAsync();


            return _mapper.Map<Model.Proizvod>(set);

        }
          
    }
}