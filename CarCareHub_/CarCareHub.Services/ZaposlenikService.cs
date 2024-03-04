using AutoMapper;
using CarCareHub.Services.Database;
using CarCareHub.Model;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Logging;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using CarCareHub.Model.SearchObjects;
using System.Security.Cryptography;

namespace CarCareHub.Services
{

    public class ZaposlenikService : BaseCRUDService<Model.Zaposlenik, Database.Zaposlenik, ZaposlenikSearchObject, ZaposlenikInsert, ZaposlenikUpdate> ,IZaposlenikService
    {


        public ZaposlenikService(Database.CchV2AliContext dbContext, IMapper mapper) : base(dbContext, mapper)
        {

        }
     

        public override async Task BeforeInsert(Database.Zaposlenik tdb, ZaposlenikInsert insert)
        {
            tdb.LozinkaSalt = GenerateSalt();
            tdb.LozinkaHash = GenerateHash(tdb.LozinkaSalt, insert.Password);
        }

        public static string GenerateSalt()
        {
            RNGCryptoServiceProvider provider = new RNGCryptoServiceProvider();
            var byteArray = new byte[16];
            provider.GetBytes(byteArray);
            return Convert.ToBase64String(byteArray);   
        }

        public static string GenerateHash(string salt, string password)
        {
            byte[] src = Convert.FromBase64String(salt);
            byte[] bytes = Encoding.Unicode.GetBytes(password);
            byte[] dst = new byte[src.Length + bytes.Length];
            System.Buffer.BlockCopy(src, 0, dst, 0, src.Length);
            System.Buffer.BlockCopy(bytes,0 , dst, src.Length, bytes.Length);
            HashAlgorithm alorithm = HashAlgorithm.Create("SHA1");
            byte[] inArray = alorithm.ComputeHash(dst);
            
            return Convert.ToBase64String(inArray);
        }

        //public Model.Zaposlenik Update(int id, ZaposlenikUpdate update)
        //{
        //    var entity = _dbContext.Zaposleniks.Find(id);

        //    _mapper.Map(update, entity);

        //    _dbContext.SaveChanges();
        //    return _mapper.Map<Model.Zaposlenik>(entity);
        //}

        public override IQueryable<Database.Zaposlenik> AddInclude(IQueryable<Database.Zaposlenik> query, ZaposlenikSearchObject? search = null)
        {
            if (search?.IsUlogeIncluded == true)
            {
                query = query.Include(entity => entity.Uloga); // Promijeniti "Uloges" u "Uloga" ako je ovo pravilno ime navigacijskog svojstva

            }
            return base.AddInclude(query, search);
        }



    }
}

