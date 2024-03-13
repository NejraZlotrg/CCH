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
    }
}