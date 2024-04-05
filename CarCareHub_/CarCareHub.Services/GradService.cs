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
    public class GradService : BaseCRUDService<Model.Grad, Database.Grad, GradSearchObject, GradInsert, GradUpdate>, IGradService
    {
        public GradService(Database.CchV2AliContext dbContext, IMapper mapper) : base(dbContext, mapper)
        {
        }

        public override IQueryable<Database.Grad> AddFilter(IQueryable<Database.Grad> query, GradSearchObject? search = null)
        {
  

            if (!string.IsNullOrWhiteSpace(search?.Naziv))
            {
                query = query.Where(x => x.NazivGrada.StartsWith(search.Naziv));
            }
            return base.AddFilter(query, search);
        }

        public override IQueryable<Database.Grad> AddInclude(IQueryable<Database.Grad> query, GradSearchObject? search = null)
        {
            // Uključujemo samo entitet Uloge
            if (search?.IsDrzavaIncluded == true)
            {
                query = query.Include(z => z.Drzava);
            }
            return base.AddInclude(query, search);
        }
    }
}
