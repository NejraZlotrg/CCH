using AutoMapper;
using CarCareHub.Model;
using CarCareHub.Model.SearchObjects;
using CarCareHub.Services.Database;
using CarCareHub.Services.ProizvodiStateMachine;
using Microsoft.EntityFrameworkCore;
using System.Linq;

namespace CarCareHub.Services
{
    public class DrzavaService : BaseCRUDService<Model.Drzava, Database.Drzava, DrzavaSearchObject, DrzavaInsert, DrzavaUpdate>, IDrzavaService
    {
        public DrzavaService(Database.CchV2AliContext dbContext, IMapper mapper) : base(dbContext, mapper)
        {
        }
        public override Task<Model.Drzava> Insert(Model.DrzavaInsert insert)
        {
            return base.Insert(insert);
        }

        public override async Task<Model.Drzava> Update(int id, Model.DrzavaUpdate update)
        {
            var entity = await _dbContext.Proizvods.FindAsync(id);
            return await base.Update(id, update);
        }

        public override async Task<Model.Drzava> Delete(int id)
        {
            var entity = await _dbContext.Proizvods.FindAsync(id);
            return await base.Delete(id);
        }



        public override IQueryable<Database.Drzava> AddFilter(IQueryable<Database.Drzava> query, DrzavaSearchObject search = null)
        {
            if (!string.IsNullOrWhiteSpace(search?.NazivDrzave))
            {
                query = query.Where(x => x.NazivDrzave.StartsWith(search.NazivDrzave));
            }
            return base.AddFilter(query, search);
        }

    }
}
