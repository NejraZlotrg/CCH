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
    public class ModelService :BaseCRUDService<Model.Model, Database.Model, ModelSearchObject, ModelInsert, ModelUpdate>, IModelService
    {
        public ModelService(Database.CchV2AliContext dbContext, IMapper mapper, IHttpContextAccessor httpContextAccessor) : base(dbContext, mapper, httpContextAccessor)
    {
    }

    public override IQueryable<Database.Model> AddFilter(IQueryable<Database.Model> query, ModelSearchObject? search = null)
    {


        if (!string.IsNullOrWhiteSpace(search?.NazivModela))
        {
            query = query.Where(x => x.NazivModela.StartsWith(search.NazivModela));
        }
            if (!string.IsNullOrWhiteSpace(search?.MarkaVozila))
            {
                query = query.Where(x => x.Vozilo.MarkaVozila.StartsWith(search.MarkaVozila));
            }
            if (search?.Godiste_ != null)
            {
                query = query.Where(x => x.Godiste.Godiste_ == search.Godiste_);
            }
            return base.AddFilter(query, search);

            return base.AddFilter(query, search);
    }


    public override IQueryable<Database.Model> AddInclude(IQueryable<Database.Model> query, ModelSearchObject? search = null)
    {
        // Uključujemo samo entitet Uloge
        if (search?.IsAllIncluded == true)
        {
            query = query.Include(z => z.Vozilo);
                query = query.Include(z => z.Godiste);

            }
            return base.AddInclude(query, search);
    }
}

}
