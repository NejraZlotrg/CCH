using AutoMapper;
using CarCareHub.Model.SearchObjects;
using CarCareHub.Model;
using Microsoft.EntityFrameworkCore;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using CarCareHub.Services.Database;
using System.Security.Cryptography;

namespace CarCareHub.Services
{
    public class KlijentService : BaseCRUDService<Model.Klijent, Database.Klijent, KlijentSearchObject, KlijentInsert, KlijentUpdate>, IKlijentService
    {
        CarCareHub.Services.Database.CchV2AliContext _dbContext;


        IMapper _mapper { get; set; }

        public KlijentService(CchV2AliContext dbContext, IMapper mapper) : base(dbContext, mapper)
        {
            _dbContext = dbContext;
            _mapper = mapper;
        }

        public override async Task BeforeInsert(CarCareHub.Services.Database.Klijent entity, KlijentInsert insert)
        {
            entity.LozinkaSalt = GenerateSalt(); 
            entity.LozinkaHash = GenerateHash(entity.LozinkaSalt, insert.Password);
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
            System.Buffer.BlockCopy(bytes, 0, dst, src.Length, bytes.Length);

            HashAlgorithm algorithm = HashAlgorithm.Create("SHA1");
            byte[] inArray = algorithm.ComputeHash(dst);
            return Convert.ToBase64String(inArray);
        }

        public override IQueryable<Database.Klijent> AddFilter(IQueryable<Database.Klijent> query, KlijentSearchObject? search = null)
        {


            if (!string.IsNullOrWhiteSpace(search?.Ime))
            {
                query = query.Where(x => x.Ime.StartsWith(search.Ime));
            }
            if (!string.IsNullOrWhiteSpace(search?.Prezime))
            {
                query = query.Where(x => x.Prezime.StartsWith(search.Prezime));
            }
            return base.AddFilter(query, search);
        }
        //public override Task<Model.Klijent> Insert(Model.KlijentInsert insert)
        //{
        //    return base.Insert(insert);
        //}

        //public override async Task<Model.Klijent> Update(int id, Model.KlijentUpdate update)
        //{
        //    return await base.Update(id, update);
        //}

        //public override async Task<Model.Klijent> Delete(int id)
        //{
        //    return await base.Delete(id);
        //}


        public override IQueryable<Database.Klijent> AddInclude(IQueryable<Database.Klijent> query, KlijentSearchObject? search = null)
        {
            // Uključujemo samo entitet Uloge
            if (search?.IsAllIncluded == true)
            {
                query = query.Include(z => z.Grad);
                query = query.Include(z => z.Grad.Drzava);
                query = query.Include(z => z.ChatKlijentAutoserviss);
                query = query.Include(z => z.ChatKlijentZaposlenik);
                query = query.Include(z => z.uloga);
            }
            return base.AddInclude(query, search);
        }




        public async Task<Model.Klijent> Login(string username, string password)
        {
            var entity = await _dbContext.Klijents.FirstOrDefaultAsync(x => x.Username == username);

            if (entity == null)
            {
                return null;
            }

            var hash = GenerateHash(entity.LozinkaSalt, password);

            if (hash != entity.LozinkaHash)
            {
                return null;
            }

            return _mapper.Map<Model.Klijent>(entity);
        }
    }
}