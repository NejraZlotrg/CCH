using AutoMapper;
using CarCareHub.Model.SearchObjects;
using CarCareHub.Model;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using Microsoft.AspNetCore.Http;

namespace CarCareHub.Services
{
    public class UlogeService : BaseCRUDService<Model.Uloge, Database.Uloge, UlogeSearchObject, UlogeInsert, UlogeUpdate>, IUlogeService
    {
        public UlogeService(Database.CchV2AliContext dbContext, IMapper mapper, IHttpContextAccessor httpContextAccessor) : base(dbContext, mapper, httpContextAccessor)
        {
        }

        public override IQueryable<Database.Uloge> AddFilter(IQueryable<Database.Uloge> query, UlogeSearchObject? search = null)
        {


            if (!string.IsNullOrWhiteSpace(search?.NazivUloge))
            {
                query = query.Where(x => x.NazivUloge.StartsWith(search.NazivUloge));
            }
            return base.AddFilter(query, search);
        }

        public async Task AddUlogeAsync()
        {
            // Provjerite da li uloge već postoje u bazi
            if (!_dbContext.Uloges.Any())
            {
                // Kreirajte listu uloga za unos
                var ulogeInsert = new List<UlogeInsert>
        {
            new UlogeInsert { NazivUloge = "Zaposlenik" , Vidljivo=true},
            new UlogeInsert { NazivUloge = "Autoservis" , Vidljivo=true},
            new UlogeInsert { NazivUloge = "Firma autodijelova" , Vidljivo=true},
            new UlogeInsert { NazivUloge = "Klijent", Vidljivo=true },
            new UlogeInsert { NazivUloge = "Admin", Vidljivo=true }

        };

                // Mapirajte svaki Insert model u Database.Uloge entitet
                var ulogeEntities = ulogeInsert.Select(u => _mapper.Map<Database.Uloge>(u)).ToList();

                // Dodajte uloge u bazu podataka
                await _dbContext.Uloges.AddRangeAsync(ulogeEntities);
                await _dbContext.SaveChangesAsync();
            }
        }


    }
}
