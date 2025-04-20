using AutoMapper;
using CarCareHub.Model.SearchObjects;
using CarCareHub.Model;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using Microsoft.AspNetCore.Http;
using Microsoft.EntityFrameworkCore;

namespace CarCareHub.Services
{
    public class ProizvodjacService : BaseCRUDService<Model.Proizvodjac, Database.Proizvodjac, ProizvodjacSearchObject, ProizvodjacInsert, ProizvodjacUpdate>, IProizvodjacService
    {
        public ProizvodjacService(Database.CchV2AliContext dbContext, IMapper mapper, IHttpContextAccessor httpContextAccessor) : base(dbContext, mapper, httpContextAccessor)
        {
        }

        public override IQueryable<Database.Proizvodjac> AddFilter(IQueryable<Database.Proizvodjac> query, ProizvodjacSearchObject search = null)
        {
            if (!string.IsNullOrWhiteSpace(search?.NazivProizvodjaca))
            {
                query = query.Where(x => x.NazivProizvodjaca.StartsWith(search.NazivProizvodjaca));
            }
            return base.AddFilter(query, search);
        }



        public async Task AddInitialProizvodjacAsync()
        {
            // Provjera koliko proizvoda već postoji u bazi
            var initialCount = await _dbContext.Proizvodjacs.CountAsync();
            Console.WriteLine($"Broj proizvodjaca prije dodavanja: {initialCount}");

            // Ako nema proizvoda u bazi, dodaj tri početna proizvoda
            if (initialCount == 0)
            {
                var proizvodjac = new List<ProizvodjacInsert>
        {
            new ProizvodjacInsert
            {
               Vidljivo = true,
               NazivProizvodjaca = "Bosch",
            },
             new ProizvodjacInsert
            {
               Vidljivo = true,
               NazivProizvodjaca = "BorbeT",
            },
              new ProizvodjacInsert
            {
               Vidljivo = true,
               NazivProizvodjaca = "Genuine",
            },
               new ProizvodjacInsert
            {
               Vidljivo = true,
               NazivProizvodjaca = "AMG",
            },
                new ProizvodjacInsert
            {
               Vidljivo = true,
               NazivProizvodjaca = "SLine",
            },
        };

                // Mapiranje i dodavanje proizvoda u bazu
                var proizvodjacEntities = proizvodjac.Select(p => _mapper.Map<CarCareHub.Services.Database.Proizvodjac>(p)).ToList();
                await _dbContext.Proizvodjacs.AddRangeAsync(proizvodjacEntities);
                await _dbContext.SaveChangesAsync();
                Console.WriteLine("Proizvodjaci su dodani.");
            }

            // Provjera broja proizvoda nakon dodavanja
            var finalCount = await _dbContext.Proizvodjacs.CountAsync();
            Console.WriteLine($"Broj proizvodjaca nakon dodavanja: {finalCount}");
        }


    }
}
