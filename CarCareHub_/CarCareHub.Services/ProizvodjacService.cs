using AutoMapper;
using CarCareHub.Model.SearchObjects;
using CarCareHub.Model;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace CarCareHub.Services
{
    public class ProizvodjacService : BaseCRUDService<Model.Proizvodjac, Database.Proizvodjac, ProizvodjacSearchObject, ProizvodjacInsert, ProizvodjacUpdate>, IProizvodjacService
    {
        public ProizvodjacService(Database.CchV2AliContext dbContext, IMapper mapper) : base(dbContext, mapper)
        {
        }

        public override IQueryable<Database.Proizvodjac> AddFilter(IQueryable<Database.Proizvodjac> query, ProizvodjacSearchObject search = null)
        {
            if (!string.IsNullOrWhiteSpace(search?.NazivProizvodjaca))
            {
                query = query.Where(x => x.NazivProizvodjaca.StartsWith(search.NazivProizvodjaca));
            }
            return base.AddFilter(query, search);
        }

    }
}
