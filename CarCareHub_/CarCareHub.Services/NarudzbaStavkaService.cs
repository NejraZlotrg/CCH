using AutoMapper;
using CarCareHub.Model.SearchObjects;
using CarCareHub.Model;
using CarCareHub.Services.Database;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Security.Cryptography;
using System.Text;
using System.Threading.Tasks;
using Microsoft.EntityFrameworkCore;
using Microsoft.AspNetCore.Http;

namespace CarCareHub.Services
{
    public class NarudzbaStavkaService : BaseCRUDService<Model.NarudzbaStavka, Database.NarudzbaStavka, NarudzbaStavkaSearchObject, NarudzbaStavkaInsert, NarudzbaStavkaUpdate>, INarudzbaStavkaService
    {
        CarCareHub.Services.Database.CchV2AliContext _dbContext;
        IMapper _mapper { get; set; }
        public NarudzbaStavkaService(CchV2AliContext dbContext, IMapper mapper, IHttpContextAccessor httpContextAccessor) : base(dbContext, mapper, httpContextAccessor)
        {
            _dbContext = dbContext;
            _mapper = mapper;
        }
        public override async Task<Model.NarudzbaStavka> Insert(Model.NarudzbaStavkaInsert insert)
        {
            insert.Vidljivo = true;
            var narudzbaStavka = _mapper.Map<Database.NarudzbaStavka>(insert);
            await _dbContext.NarudzbaStavkas.AddAsync(narudzbaStavka);
            await _dbContext.SaveChangesAsync();

            return _mapper.Map<Model.NarudzbaStavka>(narudzbaStavka);
        }
        public override async Task<Model.NarudzbaStavka> Update(int id, Model.NarudzbaStavkaUpdate update)
        {
            return await base.Update(id, update);
        }
        public override async Task<Model.NarudzbaStavka> Delete(int id)
        {
            return await base.Delete(id);
        }
        public class SearchResult<T>
        {
            public List<T> Result { get; set; }
            public int Count { get; set; }
        }
        public override IQueryable<Database.NarudzbaStavka> AddInclude(IQueryable<Database.NarudzbaStavka> query, NarudzbaStavkaSearchObject? search = null)
        {
            if (search?.IsAllncluded == true)
            {
                query = query.Include(z => z.Narudzba);
                query = query.Include(z => z.Proizvod);
            }
            return base.AddInclude(query, search);
        }
        public async Task<SearchResult<Model.NarudzbaStavka>> GetByNarudzbaID(int id)
        {
            var query = _dbContext.NarudzbaStavkas
                .Include(s => s.Narudzba).Include(b=>b.Proizvod)
                .Where(s => s.NarudzbaId == id)
                .AsQueryable();
            var count = await query.CountAsync();
            var entities = await query.ToListAsync();
            var mapped = _mapper.Map<List<Model.NarudzbaStavka>>(entities);
            
            return new SearchResult<Model.NarudzbaStavka>
            {
                Result = mapped,
                Count = count
            };
        }
    }
}


       
       
    

