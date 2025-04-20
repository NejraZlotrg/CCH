using AutoMapper;
using CarCareHub.Model;
using CarCareHub.Model.SearchObjects;
using Microsoft.AspNetCore.Http;
using Microsoft.EntityFrameworkCore;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;

namespace CarCareHub.Services
{
    public class GodisteService : BaseCRUDService<Model.Godiste, Database.Godiste, GodisteSearchObject, GodisteInsert, GodisteUpdate>, IGodisteService
    {
       

        public GodisteService(Database.CchV2AliContext dbContext, IMapper mapper, IHttpContextAccessor httpContextAccessor)
            : base(dbContext, mapper, httpContextAccessor)
        {
        }

        public override IQueryable<Database.Godiste> AddFilter(IQueryable<Database.Godiste> query, GodisteSearchObject? search = null)
        {
            if (search?.Godiste_ != null)
            {
                query = query.Where(x => x.Godiste_.ToString().StartsWith(search.Godiste_.ToString()));
            }
            return base.AddFilter(query, search);
        }

        // You can uncomment the AddInclude method if needed for including related entities
        //public override IQueryable<Database.Godiste> AddInclude(IQueryable<Database.Godiste> query, GodisteSearchObject? search = null)
        //{
        //    if (search?.IsAllIncluded == true)
        //    {
        //        // Add include logic if necessary
        //    }
        //    return base.AddInclude(query, search);
        //}

        // Method to add default records to the database if no records exist
        public async Task AddGodisteAsync()
        {
            // Provjerite koliko zapisa već postoji u bazi
            var initialCount = await _dbContext.Godistes.CountAsync();
            Console.WriteLine($"Broj zapisa prije dodavanja: {initialCount}");

            // Provjerite da li već postoji unos u bazi
            if (!_dbContext.Godistes.Any())
            {
                // Kreirajte listu novih zapisa za unos
                var godisteInsert = new List<GodisteInsert>
        {
            new GodisteInsert { Godiste_ = 2000, Vidljivo = true },
            new GodisteInsert { Godiste_ = 2001, Vidljivo = true },
            new GodisteInsert { Godiste_ = 2002, Vidljivo = true },
            new GodisteInsert { Godiste_ = 2003, Vidljivo = true },
            new GodisteInsert { Godiste_ = 2004, Vidljivo = true }
        };

                // Mapirajte svaki Insert model u Database.Godiste entitet
                var godisteEntities = godisteInsert.Select(g => _mapper.Map<Database.Godiste>(g)).ToList();

                // Dodajte zapise u bazu podataka
                await _dbContext.Godistes.AddRangeAsync(godisteEntities);
                await _dbContext.SaveChangesAsync();
            }

            // Provjerite koliko zapisa sada postoji
            var finalCount = await _dbContext.Godistes.CountAsync();
            Console.WriteLine($"Broj zapisa nakon dodavanja: {finalCount}");
        }

    }
}
