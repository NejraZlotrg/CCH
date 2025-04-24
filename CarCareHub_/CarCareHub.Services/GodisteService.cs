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
        public async Task AddGodisteAsync()
        {
            var initialCount = await _dbContext.Godistes.CountAsync();
            Console.WriteLine($"Broj zapisa prije dodavanja: {initialCount}");
            if (!_dbContext.Godistes.Any())
            {
                var godisteInsert = new List<GodisteInsert>
        {
            new GodisteInsert { Godiste_ = 2000, Vidljivo = true },
            new GodisteInsert { Godiste_ = 2001, Vidljivo = true },
            new GodisteInsert { Godiste_ = 2002, Vidljivo = true },
            new GodisteInsert { Godiste_ = 2003, Vidljivo = true },
            new GodisteInsert { Godiste_ = 2004, Vidljivo = true }
        };
                var godisteEntities = godisteInsert.Select(g => _mapper.Map<Database.Godiste>(g)).ToList();
                await _dbContext.Godistes.AddRangeAsync(godisteEntities);
                await _dbContext.SaveChangesAsync();
            }
            var finalCount = await _dbContext.Godistes.CountAsync();
            Console.WriteLine($"Broj zapisa nakon dodavanja: {finalCount}");
        }
    }
}
