using AutoMapper;
using CarCareHub.Model.SearchObjects;
using CarCareHub.Model;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using Microsoft.EntityFrameworkCore;
using Microsoft.AspNetCore.Http;

namespace CarCareHub.Services
{
    public class UslugeService : BaseCRUDService<Model.Usluge, Database.Usluge, UslugeSearchObject, UslugeInsert, UslugeUpdate>, IUslugeService
    {
        public UslugeService(Database.CchV2AliContext dbContext, IMapper mapper, IHttpContextAccessor httpContextAccessor) : base(dbContext, mapper, httpContextAccessor)
        {
        }
        public override IQueryable<Database.Usluge> AddFilter(IQueryable<Database.Usluge> query, UslugeSearchObject? search = null)
        {
            if (!string.IsNullOrWhiteSpace(search?.NazivUsluge))
            {
                query = query.Where(x => x.NazivUsluge.StartsWith(search.NazivUsluge));
            }
            return base.AddFilter(query, search);
        }
        public override async Task<List<Usluge>> GetByID_(int id)
        {
            var temp = _dbContext.Usluges.Where(x => x.autoservisId == id).ToList().AsQueryable();
            temp = temp.Include(x => x.Autoservis);
            return _mapper.Map<List<Usluge>>(temp);
        }
        public async Task AddInitialUslugeAsync()
        {
            var initialCount = await _dbContext.Usluges.CountAsync();
            Console.WriteLine($"Broj usluga prije dodavanja: {initialCount}");
            if (initialCount == 0)
            {
                var usluge = new List<UslugeInsert>
        {
            new UslugeInsert
            {
               Vidljivo = true,
               NazivUsluge = "Mali servis",
               AutoservisId = 1,
               Cijena = 100,
               Opis = "Osnovni servis."
            },
            new UslugeInsert
            {
               Vidljivo = true,
               NazivUsluge = "Zamjena guma",
               AutoservisId = 1,
               Cijena = 150,
               Opis = "Promjena sezonskih guma."
            },
            new UslugeInsert
            {
               Vidljivo = true,
               NazivUsluge = "Čišćenje DPF",
               AutoservisId = 1,
               Cijena = 200,
               Opis = "Čišćenje dpf filtera."
            },
        };
                var uslugeEntities = usluge.Select(p => _mapper.Map<CarCareHub.Services.Database.Usluge>(p)).ToList();
                await _dbContext.Usluges.AddRangeAsync(uslugeEntities);
                await _dbContext.SaveChangesAsync();
                Console.WriteLine("Usluge su dodane.");
            }
            var finalCount = await _dbContext.Usluges.CountAsync();
            Console.WriteLine($"Broj usuga nakon dodavanja: {finalCount}");
        }
    }
}
