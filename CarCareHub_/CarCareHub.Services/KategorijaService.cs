using AutoMapper;
using CarCareHub.Model;
using CarCareHub.Model.SearchObjects;
using CarCareHub.Services.Database;
using Microsoft.AspNetCore.Http;
using Microsoft.EntityFrameworkCore;
using System.Linq;
using System.Threading.Tasks;
using System.Collections.Generic;

namespace CarCareHub.Services
{
    public class KategorijaService : BaseCRUDService<Model.Kategorija, Database.Kategorija, KategorijaSearchObject, KategorijaInsert, KategorijaUpdate>, IKategorijaService
    {
        public KategorijaService(Database.CchV2AliContext dbContext, IMapper mapper, IHttpContextAccessor httpContextAccessor) : base(dbContext, mapper, httpContextAccessor)
        {
        }
        public override IQueryable<Database.Kategorija> AddFilter(IQueryable<Database.Kategorija> query, KategorijaSearchObject search = null)
        {
            if (!string.IsNullOrWhiteSpace(search?.NazivKategorije))
            {
                query = query.Where(x => x.NazivKategorije.StartsWith(search.NazivKategorije));
            }
            return base.AddFilter(query, search);
        }
        public async Task AddKategorijaAsync()
        {
            var initialCount = await _dbContext.Kategorijas.CountAsync();
            Console.WriteLine($"Broj kategorija prije dodavanja: {initialCount}");
            if (initialCount == 0)
            {
                var kategorijaInsert = new List<KategorijaInsert>
                {
                    new KategorijaInsert { NazivKategorije = "Automobili", Vidljivo = true },
                    new KategorijaInsert { NazivKategorije = "Motocikli", Vidljivo = true },
                    new KategorijaInsert { NazivKategorije = "Kamioni", Vidljivo = true }
                };
                var kategorijaEntities = kategorijaInsert.Select(k => _mapper.Map<Database.Kategorija>(k)).ToList();
                await _dbContext.Kategorijas.AddRangeAsync(kategorijaEntities);
                await _dbContext.SaveChangesAsync();
                Console.WriteLine("Kategorije su dodane.");
            }
            var finalCount = await _dbContext.Kategorijas.CountAsync();
            Console.WriteLine($"Broj kategorija nakon dodavanja: {finalCount}");
        }
    }
}
