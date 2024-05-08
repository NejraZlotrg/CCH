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
    public class BPAutodijeloviAutoservisService : BaseCRUDService<Model.BPAutodijeloviAutoservis, Database.BPAutodijeloviAutoservis, BPAutodijeloviAutoservisSearchObject, BPAutodijeloviAutoservisInsert, BPAutodijeloviAutoservisUpdate>, IBPAutodijeloviAutoservisService
    {
        public BPAutodijeloviAutoservisService(Database.CchV2AliContext dbContext, IMapper mapper) : base(dbContext, mapper)
        {
        }


        public override IQueryable<Database.BPAutodijeloviAutoservis> AddFilter(IQueryable<Database.BPAutodijeloviAutoservis> query, BPAutodijeloviAutoservisSearchObject? search = null)
        {

            if (search?.AutoservisID!=null)
            {
                query = query.Where(x => x.Autoservis.AutoservisId == search.AutoservisID);
            }
            if (search?.AutodijeloviID!=null)
            {
                query = query.Where(x => x.FirmaAutodijelova.FirmaAutodijelovaID == search.AutodijeloviID);
            }
            return base.AddFilter(query, search);
        }
        public override IQueryable<Database.BPAutodijeloviAutoservis> AddInclude(IQueryable<Database.BPAutodijeloviAutoservis> query, BPAutodijeloviAutoservisSearchObject? search = null)
        {
            // Uključujemo samo entitet Uloge
            if (search?.IsAllIncluded == true)
            {
                query = query.Include(z => z.FirmaAutodijelova);
                query = query.Include(z => z.Autoservis);


            }
            return base.AddInclude(query, search);
        }
    }
}
