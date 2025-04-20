using AutoMapper;
using CarCareHub.Model.SearchObjects;
using CarCareHub.Model;
using Microsoft.EntityFrameworkCore;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using Microsoft.AspNetCore.Http;

namespace CarCareHub.Services
{
    public class VoziloService : BaseCRUDService<Model.Vozilo, Database.Vozilo, VoziloSearchObject, VoziloInsert, VoziloUpdate>, IVoziloService
    {
        public VoziloService(Database.CchV2AliContext dbContext, IMapper mapper, IHttpContextAccessor httpContextAccessor) : base(dbContext, mapper, httpContextAccessor)
        {
        }
      


        public override IQueryable<Database.Vozilo> AddFilter(IQueryable<Database.Vozilo> query, VoziloSearchObject? search = null)
        {


            if (!string.IsNullOrWhiteSpace(search?.MarkaVozila))
            {
                query = query.Where(x => x.MarkaVozila.StartsWith(search.MarkaVozila));
            }
            return base.AddFilter(query, search);
        }

        public async Task AddVoziloAsync()
        {
            // Provjerite da li vozila već postoje u bazi
            if (!_dbContext.Vozilos.Any())
            {
                // Kreirajte listu vozila za unos
                var vozilaInsert = new List<VoziloInsert>
        {
            new VoziloInsert { MarkaVozila = "Volkswagen"},
            new VoziloInsert { MarkaVozila = "BMW" },
            new VoziloInsert { MarkaVozila = "Audi" },
            new VoziloInsert { MarkaVozila = "Mercedes" }
        };

                // Mapirajte svaki Insert model u Database.Vozilo entitet i postavite Vidljivo na true
                var voziloEntities = vozilaInsert.Select(v =>
                {
                    var vozilo = _mapper.Map<Database.Vozilo>(v);
                    vozilo.Vidljivo = true;  // Postavite Vidljivo na true
                    return vozilo;
                }).ToList();

                // Dodajte vozila u bazu podataka
                await _dbContext.Vozilos.AddRangeAsync(voziloEntities);
                await _dbContext.SaveChangesAsync();
            }
        }



    }
}
