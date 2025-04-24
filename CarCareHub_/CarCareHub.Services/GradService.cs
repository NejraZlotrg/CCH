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
using Microsoft.AspNetCore.Http;

namespace CarCareHub.Services
{
    public class GradService : BaseCRUDService<Model.Grad, Database.Grad, GradSearchObject, GradInsert, GradUpdate>, IGradService
    {
        public GradService(Database.CchV2AliContext dbContext, IMapper mapper, IHttpContextAccessor httpContextAccessor) : base(dbContext, mapper, httpContextAccessor)
        {
        }
        public override IQueryable<Database.Grad> AddFilter(IQueryable<Database.Grad> query, GradSearchObject? search = null)
        {
            if (!string.IsNullOrWhiteSpace(search?.NazivGrada))
            {
                query = query.Where(x => x.NazivGrada.StartsWith(search.NazivGrada));
            }
            return base.AddFilter(query, search);
        }
        public override IQueryable<Database.Grad> AddInclude(IQueryable<Database.Grad> query, GradSearchObject? search = null)
        {
            if (search?.IsDrzavaIncluded == true)
            {
                query = query.Include(z => z.Drzava);
            }
            return base.AddInclude(query, search);
        }
        public async Task AddGradAsync()
        {
            if (!_dbContext.Grads.Any())
            {
                var gradoviInsert = new List<GradInsert>
        {
            new GradInsert { NazivGrada = "Sarajevo", DrzavaId = 1 , Vidljivo=true}, 
            new GradInsert { NazivGrada = "Zagreb", DrzavaId = 2, Vidljivo=true }, 
            new GradInsert { NazivGrada = "Beograd", DrzavaId = 3 , Vidljivo=true}, 
            new GradInsert { NazivGrada = "Skopje", DrzavaId = 4 , Vidljivo=true }
        };
                var gradEntities = gradoviInsert.Select(g => _mapper.Map<Database.Grad>(g)).ToList();
                await _dbContext.Grads.AddRangeAsync(gradEntities);
                await _dbContext.SaveChangesAsync();
            }
        }
    }
}
