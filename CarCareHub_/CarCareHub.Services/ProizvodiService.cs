using AutoMapper;
using CarCareHub.Services.Database;
using CarCareHub.Services.ProizvodiStateMachine;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace CarCareHub.Services
{
    public class ProizvodiService : BaseCRUDService<Model.Proizvod, Proizvod, CarCareHub.Model.SearchObjects.ProizvodiSearchObject, Model.ProizvodiInsert, Model.ProizvodiUpdate>
        , IProizvodiService
    {
        public BaseState _baseState { get; set; }
        public ProizvodiService(BaseState baseState, CchV2AliContext dbContext, IMapper mapper) : base(dbContext, mapper)
        {
            _baseState = baseState;
        }

        public override Task<Model.Proizvod> Insert(Model.ProizvodiInsert insert)
        {
            var state = _baseState.CreateState("initial");
            return state.Insert(insert);
        }

        public override async Task<Model.Proizvod> Update(int id, Model.ProizvodiUpdate update)
        {
            var entity = await _dbContext.Proizvods.FindAsync(id);
            var state = _baseState.CreateState(entity.StateMachine);
            return await state.Update(id, update);
        }

        

        public async Task<Model.Proizvod> Activate(int id)
        {
            var entity = await _dbContext.Proizvods.FindAsync(id);
            var state = _baseState.CreateState(entity.StateMachine);
            return await state.Activate(id);
        }

        public async Task<Model.Proizvod> Hide(int id)
        {
            var entity = await _dbContext.Proizvods.FindAsync(id);
            var state = _baseState.CreateState(entity.StateMachine);
            return await state.Hide(id);
        }

        public async Task<List<string>> AllowedActions (int id)
        {
            var entity = await _dbContext.Proizvods.FindAsync(id);
            var state = _baseState.CreateState(entity?.StateMachine ?? "initial");
            return await state.AllowedActions(id);
        }

       
    }
}
