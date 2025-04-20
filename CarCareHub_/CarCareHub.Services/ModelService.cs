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
        public async Task AddModelAsync()
        {
            // Provjerite da li modeli već postoje u bazi
            if (!_dbContext.Models.Any())
            {
                // Kreirajte listu modela za unos
                var modeliInsert = new List<ModelInsert>
        {
            new ModelInsert { NazivModela = "Audi A4", VoziloId = 1, GodisteId = 1, Vidljivo = true },
            new ModelInsert { NazivModela = "BMW X5", VoziloId = 2, GodisteId = 2, Vidljivo = true },
            new ModelInsert { NazivModela = "Mercedes-Benz E-Class", VoziloId = 3, GodisteId = 3, Vidljivo = true },
            new ModelInsert { NazivModela = "Tesla Model 3", VoziloId = 4, GodisteId = 4, Vidljivo = true }
        };

                // Mapirajte svaki Insert model u Database.Model entitet
                var modelEntities = modeliInsert.Select(m => _mapper.Map<Database.Model>(m)).ToList();

                // Dodajte modele u bazu podataka
                await _dbContext.Models.AddRangeAsync(modelEntities);
                await _dbContext.SaveChangesAsync();
            }
        }

    }

}
