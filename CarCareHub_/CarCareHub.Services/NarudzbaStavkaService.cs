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
            var narudzbaStavka = _mapper.Map<Database.NarudzbaStavka>(insert);

            // Dobavljanje cijene proizvoda iz baze podataka DODATI U KORPU
           
            // Spremanje u bazu podataka
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
        
        
      

        public override IQueryable<Database.NarudzbaStavka> AddInclude(IQueryable<Database.NarudzbaStavka> query, NarudzbaStavkaSearchObject? search = null)
        {
            // Uključujemo samo entitet Uloge
            if (search?.IsAllncluded == true)
            {
              
                query = query.Include(z => z.Narudzba);
                query = query.Include(z => z.Proizvod);
             
            }
            return base.AddInclude(query, search);
        }

        //public static string GenerateSalt()
        //{
        //    RNGCryptoServiceProvider provider = new RNGCryptoServiceProvider();
        //    var byteArray = new byte[16];
        //   provider.GetBytes(byteArray);


        //    return Convert.ToBase64String(byteArray);
        //}
        //public static string GenerateHash(string salt, string password)
        //{
        //    byte[] src = Convert.FromBase64String(salt);
        //    byte[] bytes = Encoding.Unicode.GetBytes(password);
        //    byte[] dst = new byte[src.Length + bytes.Length];

        //    System.Buffer.BlockCopy(src, 0, dst, 0, src.Length);
        //    System.Buffer.BlockCopy(bytes, 0, dst, src.Length, bytes.Length);

        //    HashAlgorithm algorithm = HashAlgorithm.Create("SHA1");
        //    byte[] inArray = algorithm.ComputeHash(dst);
        //    return Convert.ToBase64String(inArray);
        //}


    }
}


       
       
    

