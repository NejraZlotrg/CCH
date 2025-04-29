using AutoMapper;
using CarCareHub.Model;
using CarCareHub.Model.SearchObjects;
using Microsoft.AspNetCore.Http;
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
        public BPAutodijeloviAutoservisService(Database.CchV2AliContext dbContext, IMapper mapper, IHttpContextAccessor httpContextAccessor) : base(dbContext, mapper, httpContextAccessor)
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
            if (search?.IsAllIncluded == true)
            {
                query = query.Include(z => z.FirmaAutodijelova);
                query = query.Include(z => z.Autoservis);
            }
            return base.AddInclude(query, search);
        }
        public IQueryable<Database.BPAutodijeloviAutoservis> AutoservisInclude(IQueryable<Database.BPAutodijeloviAutoservis> query, BPAutodijeloviAutoservisSearchObject? search = null)
        {
            if (search?.IsAllIncluded == true)
            {
                query = query.Include(z => z.Autoservis);
            }
            return base.AddInclude(query, search);
        }
        public override async Task<List<Model.BPAutodijeloviAutoservis>> GetByID_(int id)
        {
            var query = _dbContext.BPAutodijeloviAutoservis
                .Where(x => x.FirmaAutodijelova.FirmaAutodijelovaID == id)
                .AsQueryable();

            query = AutoservisInclude(query, new BPAutodijeloviAutoservisSearchObject { IsAllIncluded = true });

            var result = await query.ToListAsync();

            // Filtriranje po "Vidljivo" ako postoji takva kolona
            var filtered = result.Where(x =>
            {
                var prop = x.GetType().GetProperty("Vidljivo");
                return prop == null || (bool)(prop.GetValue(x) ?? false);
            }).ToList();

            return _mapper.Map<List<Model.BPAutodijeloviAutoservis>>(filtered);
        }

    }
}