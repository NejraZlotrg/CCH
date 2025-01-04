using AutoMapper;
using CarCareHub.Model;
using CarCareHub.Model.SearchObjects;
using CarCareHub.Services.Database;
using CarCareHub.Services.ProizvodiStateMachine;
using Microsoft.EntityFrameworkCore;
using System.Linq;

namespace CarCareHub.Services
{

    public class DrzavaService : BaseCRUDService<Model.Drzava, Database.Drzava, DrzavaSearchObject, DrzavaInsert, DrzavaUpdate>, IDrzavaService
    {
        public DrzavaService(Database.CchV2AliContext dbContext, IMapper mapper) : base(dbContext, mapper)
        {
        }
        public override Task<Model.Drzava> Insert(Model.DrzavaInsert insert)
        {
            return base.Insert(insert);
        }

        public override async Task<Model.Drzava> Update(int id, Model.DrzavaUpdate update)
        {
            var entity = await _dbContext.Proizvods.FindAsync(id);
            return await base.Update(id, update);
        }

        public override async Task<Model.Drzava> Delete(int id)
        {
            var entity = await _dbContext.Proizvods.FindAsync(id);
            return await base.Delete(id);
        }


        public override IQueryable<Database.Drzava> AddFilter(IQueryable<Database.Drzava> query, DrzavaSearchObject? search=null)
        {
            if (search != null)
            {
                // Filtriranje po nazivu države
                if (!string.IsNullOrWhiteSpace(search.NazivDrzave))
                {
                    query = query.Where(x => x.NazivDrzave.ToLower().StartsWith(search.NazivDrzave.ToLower()));
                }
            }

            return base.AddFilter(query, search);
        }




        //public override IQueryable<Database.Drzava> AddFilter(IQueryable<Database.Drzava> query, DrzavaSearchObject search = null)
        //{
        //    if (!string.IsNullOrWhiteSpace(search?.NazivDrzave))
        //    {
        //        // Logiranje vrijednosti pretrage
        //        Console.WriteLine($"Pretraga po nazivu države: {search.NazivDrzave}");

        //        query = query.Where(x => x.NazivDrzave.ToLower().StartsWith(search.NazivDrzave.ToLower()));
        //    }
        //    else
        //    {
        //        Console.WriteLine("Pretraga je prazna ili null.");
        //    }
        //    return base.AddFilter(query, search);
        //}

        public async Task AddDrzavaAsync()
        {
            // Provjerite da li uloge već postoje u bazi
            if (!_dbContext.Drzavas.Any())
            {
                // Kreirajte listu uloga za unos
                var ulogeInsert = new List<DrzavaInsert>
        {
            new DrzavaInsert {  NazivDrzave = "Bosna i Hercegovina" },
            new DrzavaInsert {  NazivDrzave = "Hrvatska" },
            new DrzavaInsert {  NazivDrzave = "Srbija" },
            new DrzavaInsert {  NazivDrzave = "Makedonija" },

        };

                // Mapirajte svaki Insert model u Database.Uloge entitet
                var Entities = ulogeInsert.Select(u => _mapper.Map<Database.Drzava>(u)).ToList();

                // Dodajte uloge u bazu podataka
                await _dbContext.Drzavas.AddRangeAsync(Entities);
                await _dbContext.SaveChangesAsync();
            }
        }

    }
}
