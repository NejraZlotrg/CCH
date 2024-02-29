using AutoMapper;
using CarCareHub.Model;
using Microsoft.EntityFrameworkCore;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using CarCareHub.Services.Database;
using CarCareHub.Model.SearchObjects;

namespace CarCareHub.Services
{
    public class GradService : BaseService <Model.Grad, Database.Grad, CarCareHub.Model.SearchObjects.GradSearchObject>, IGradService

    {


        public GradService(Database.CchV2AliContext dbContext, IMapper mapper): base(dbContext, mapper)
        {
           
        }

        public override async Task<List<Model.Grad>> Get(GradSearchObject search)
        {
            var query = _dbContext.Set<Database.Grad>().AsQueryable();

            if (!string.IsNullOrWhiteSpace(search.Naziv))
            {
                query = query.Where(x => x.NazivGrada.StartsWith(search.Naziv));
            }
            var list = await query.ToListAsync();
            return _mapper.Map<List<Model.Grad>>(list);
        }
    }
}
