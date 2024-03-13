using AutoMapper;
using Microsoft.Extensions.DependencyInjection;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace CarCareHub.Services.ProizvodiStateMachine
{
    public class BaseState
    {
        protected CarCareHub.Services.Database.CchV2AliContext _dbContext;
        protected IMapper _mapper { get; set; }
        public IServiceProvider _serviceProvider { get; set; }

        public BaseState(Database.CchV2AliContext dbContext, IMapper mapper, IServiceProvider serviceProvider)
        {
            _dbContext = dbContext;
            _mapper = mapper;
            _serviceProvider = serviceProvider;
        }

        public virtual Task<Model.Proizvod> Insert(CarCareHub.Model.ProizvodiInsert insert)
        {
            throw new Exception("not allowed");
        }

        public virtual Task<Model.Proizvod> Update(int id, CarCareHub.Model.ProizvodiUpdate insert)
        {
            throw new Exception("not allowed");
        }

        public virtual Task<Model.Proizvod> Activate(int id)
        {
            throw new Exception("not allowed");
        }

        public virtual Task<Model.Proizvod> Hide(int id)
        {
            throw new Exception("not allowed");
        }
        public virtual Task<Model.Proizvod> Delete(int id)
        {
            throw new Exception("not allowed");
        }

        public BaseState CreateState(string stateName)
        {
            switch (stateName)
            {
                case "initial":
                    return _serviceProvider.GetService<InitialProductState>();
                    break;
                case "draft":
                    return _serviceProvider.GetService<DraftProductState>();
                    break;
                case "active":
                    return _serviceProvider.GetService<ActiveProductState>();
                    break;
                default:
                    throw new Exception("not allowed");
            }
        }
    }
}