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
    public class UlogeService : BaseCRUDService<Model.Uloge, Database.Uloge, UlogeSearchObject, UlogeInsert, UlogeUpdate>, IUlogeService
    {
        public UlogeService(Database.CchV2AliContext dbContext, IMapper mapper) : base(dbContext, mapper)
        {
        }

        public override IQueryable<Database.Uloge> AddFilter(IQueryable<Database.Uloge> query, UlogeSearchObject? search = null)
        {


            if (!string.IsNullOrWhiteSpace(search?.NazivUloge))
            {
                query = query.Where(x => x.NazivUloge.StartsWith(search.NazivUloge));
            }
            return base.AddFilter(query, search);
        }
    }
}
