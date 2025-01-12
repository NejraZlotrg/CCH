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
  

            if (!string.IsNullOrWhiteSpace(search?.NazivGrada))
            {
                query = query.Where(x => x.NazivGrada.StartsWith(search.NazivGrada));
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
        public async Task AddGradAsync()
        {
            // Provjerite da li gradovi već postoje u bazi
            if (!_dbContext.Grads.Any())
            {
                // Kreirajte listu gradova za unos
                var gradoviInsert = new List<GradInsert>
        {
            new GradInsert { NazivGrada = "Sarajevo", DrzavaId = 1 }, // Assuming DrzavaId = 1 corresponds to Bosnia and Herzegovina
            new GradInsert { NazivGrada = "Zagreb", DrzavaId = 2 }, // DrzavaId = 2 corresponds to Croatia
            new GradInsert { NazivGrada = "Beograd", DrzavaId = 3 }, // DrzavaId = 3 corresponds to Serbia
            new GradInsert { NazivGrada = "Skopje", DrzavaId = 4 }  // DrzavaId = 4 corresponds to North Macedonia
        };

                // Mapirajte svaki Insert model u Database.Grad entitet
                var gradEntities = gradoviInsert.Select(g => _mapper.Map<Database.Grad>(g)).ToList();

                // Dodajte gradove u bazu podataka
                await _dbContext.Grads.AddRangeAsync(gradEntities);
                await _dbContext.SaveChangesAsync();
            }
        }

    }
}
