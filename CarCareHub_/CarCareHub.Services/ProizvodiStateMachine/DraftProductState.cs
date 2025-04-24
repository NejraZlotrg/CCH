using AutoMapper;
using CarCareHub.Model;
using CarCareHub.Model.Messages;
using EasyNetQ;
using Microsoft.Extensions.Logging;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace CarCareHub.Services.ProizvodiStateMachine
{
    public class DraftProductState : BaseState
    {
        protected ILogger<DraftProductState> _logger;
        public DraftProductState(ILogger<DraftProductState> logger , Database.CchV2AliContext dbContext, IMapper mapper, IServiceProvider serviceProvider) : base(dbContext, mapper, serviceProvider)
        {
            _logger = logger;
        }
        public override async Task<Proizvod> Update(int id, ProizvodiUpdate insert)
        {
            var set = await _dbContext.Set<Database.Proizvod>().FindAsync(id);
            _mapper.Map(insert, set);
            if (set.Cijena < 0)
                throw new UserException("Cijena ne može biti u minusu");
            if (set.Cijena < 1)
                throw new UserException("Cijena ispod min");
            await _dbContext.SaveChangesAsync();
            return _mapper.Map<Model.Proizvod>(set);
        }
        public override async Task<Proizvod> Activate(int id)
        {
            var set = await _dbContext.Set<Database.Proizvod>().FindAsync(id);
            set.StateMachine = "active";
            await _dbContext.SaveChangesAsync();
            var MappedEntity = _mapper.Map<Model.Proizvod>(set);
            ProizvodiActivated message = new ProizvodiActivated { Proizvod = MappedEntity };
            return MappedEntity;
        }
        public override async Task<List<string>> AllowedActions(int id)
        {
            var list = await base.AllowedActions(id);
            list.Add("update");
            list.Add("activate");
            return list;
        }
    }
}