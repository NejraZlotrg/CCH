using AutoMapper;
using CarCareHub.Model;
using CarCareHub.Model.SearchObjects;
using Microsoft.EntityFrameworkCore;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace CarCareHub.Services
{
    public class AutoservisUslugeServices: BaseCRUDService<Model.AutoservisUsluge, Database.AutoservisUsluge, AutoservisUslugeSearchObject,
        AutoservisUslugeInsert, AutoservisUslugeUpdate>, IAutoservisUslugeServices
    {
        public AutoservisUslugeServices(Database.CchV2AliContext dbContext, IMapper mapper) : base(dbContext, mapper)
    {
    }

        public override IQueryable<Database.AutoservisUsluge> AddInclude(IQueryable<Database.AutoservisUsluge> query, AutoservisUslugeSearchObject? search = null)
        {
            // Uključujemo samo entitet Uloge
            if (search?.IsAllIncluded == true)
            {
                query = query.Include(z => z.Autoservis);
                query = query.Include(z => z.Usluge);
            }
            return base.AddInclude(query, search);
        }
    }
}
