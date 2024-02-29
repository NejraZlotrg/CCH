using AutoMapper;
using CarCareHub.Services.Database;
using CarCareHub.Model;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Logging;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using CarCareHub.Model.SearchObjects;

namespace CarCareHub.Services
{

    public class ZaposlenikService : BaseService<Model.Zaposlenik, Database.Zaposlenik, object> ,IZaposlenikService
    {




        public ZaposlenikService(Database.CchV2AliContext dbContext, IMapper mapper) : base(dbContext, mapper)
        {

        }

        //public override async Task<List<Model.Zaposlenik>> Get(null)
        //{
        //    var query = _dbContext.Set<Database.Zaposlenik>().AsQueryable();

        //    //if (!string.IsNullOrWhiteSpace(search))
        //    //{
        //    //    query = query.Where(x => x.NazivGrada.StartsWith(search.Naziv));
        //    //}
        //    search.Equals(null);
        //    var list = await query.ToListAsync();

        //    return _mapper.Map<List<Model.Zaposlenik>>(list);
        //}
    }
}

