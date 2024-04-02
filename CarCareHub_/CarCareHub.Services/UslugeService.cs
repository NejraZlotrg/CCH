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
    public class UslugeService : BaseCRUDService<Model.Usluge, Database.Usluge, UslugeSearchObject, UslugeInsert, UslugeUpdate>, IUslugeService
    {
        public UslugeService(Database.CchV2AliContext dbContext, IMapper mapper) : base(dbContext, mapper)
        {
        }

        public override IQueryable<Database.Usluge> AddFilter(IQueryable<Database.Usluge> query, UslugeSearchObject? search = null)
        {


            if (!string.IsNullOrWhiteSpace(search?.NazivUsluge))
            {
                query = query.Where(x => x.NazivUsluge.StartsWith(search.NazivUsluge));
            }
            return base.AddFilter(query, search);
        }
    }
}
