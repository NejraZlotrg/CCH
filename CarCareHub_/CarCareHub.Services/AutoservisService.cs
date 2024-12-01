using AutoMapper;
using CarCareHub.Model.SearchObjects;
using CarCareHub.Model;
using CarCareHub.Services.Database;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using Microsoft.EntityFrameworkCore;
using System.Security.Cryptography;

namespace CarCareHub.Services
{
    public class AutoservisService : BaseCRUDService<Model.Autoservis, Database.Autoservis, AutoservisSearchObject, AutoservisInsert, AutoservisUpdate>, IAutoservisService
    {
        CarCareHub.Services.Database.CchV2AliContext _dbContext;
        IMapper _mapper { get; set; }
        public override async Task BeforeInsert(CarCareHub.Services.Database.Autoservis entity, AutoservisInsert insert)
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
        public AutoservisService(CchV2AliContext dbContext, IMapper mapper) : base(dbContext, mapper)
        {
            _dbContext = dbContext;
            _mapper = mapper;
        }
        public override Task<Model.Autoservis> Insert(Model.AutoservisInsert insert)
        {
            return base.Insert(insert);
        }

        public override async Task<Model.Autoservis> Update(int id, Model.AutoservisUpdate update)
        {
            return await base.Update(id, update);
        }

        public override async Task<Model.Autoservis> Delete(int id)
        {
            return await base.Delete(id);
        }

        public override IQueryable<Database.Autoservis> AddInclude(IQueryable<Database.Autoservis> query, AutoservisSearchObject? search = null)
        {
            if (search?.IsAllIncluded == true)
            {
                query = query.Include(entity => entity.Grad);
                query = query.Include(entity => entity.Grad.Drzava);
                query = query.Include(entity => entity.Uloga);
                query = query.Include(entity => entity.Usluges);
                query = query.Include(entity => entity.Zaposleniks);
                query = query.Include(entity => entity.Vozilo);

            }
            return base.AddInclude(query, search);
        }
        public override IQueryable<Database.Autoservis> AddFilter(IQueryable<Database.Autoservis> query, AutoservisSearchObject search = null)
        {
           

            if (!string.IsNullOrWhiteSpace(search?.NazivGrada))
            {
                query = query.Where(x => x.Grad.NazivGrada.StartsWith(search.NazivGrada));

            }

            if (!string.IsNullOrWhiteSpace(search?.Naziv))
            {
                query = query.Where(x => x.Naziv.StartsWith(search.Naziv));

            }

            return base.AddFilter(query, search);

        }

        public async Task<Model.Autoservis> Login(string username, string password)
        {
            var entity = await _dbContext.Autoservis.Include(x => x.Uloga).FirstOrDefaultAsync(x => x.Username == username);

            if (entity == null)
            {
                return null;
            }

            var hash = GenerateHash(entity.LozinkaSalt, password);

            if (hash != entity.LozinkaHash)
            {
                return null;
            }

            return _mapper.Map<Model.Autoservis>(entity);
        }




    }
}
