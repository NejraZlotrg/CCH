using AutoMapper;
using CarCareHub.Model;
using CarCareHub.Model.SearchObjects;
using CarCareHub.Services.Database;
using Microsoft.EntityFrameworkCore;
using System.Linq;

namespace CarCareHub.Services
{
    public class DrzavaService : BaseCRUDService<Model.Drzava, Database.Drzava, DrzavaSearchObject, DrzavaInsert, DrzavaUpdate>, IDrzavaService
    {
        public DrzavaService(Database.CchV2AliContext dbContext, IMapper mapper) : base(dbContext, mapper)
        {
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
