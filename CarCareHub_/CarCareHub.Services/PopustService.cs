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

namespace CarCareHub.Services
{


    public class PopustService : BaseCRUDService<Model.Popust, Database.Popust, PopustSearchObject, PopustInsert, PopustUpdate>, IPopustService
    {
        CarCareHub.Services.Database.CchV2AliContext _dbContext;
        IMapper _mapper { get; set; }

        public PopustService(CchV2AliContext dbContext, IMapper mapper) : base(dbContext, mapper)
        {
            _dbContext = dbContext;
            _mapper = mapper;
        }
        public override Task<Model.Popust> Insert(Model.PopustInsert insert)
        {
            return base.Insert(insert);
        }

        public override async Task<Model.Popust> Update(int id, Model.PopustUpdate update)
        {
            return await base.Update(id, update);
        }

        public override async Task<Model.Popust> Delete(int id)
        {
            return await base.Delete(id);
        }


        public override IQueryable<Database.Popust> AddInclude(IQueryable<Database.Popust> query, PopustSearchObject? search = null)
        {
            // Uključujemo samo entitet Uloge
            if (search?.IsAllIncluded == true)
            {
                query = query.Include(z => z.Autoservis);
                query = query.Include(z => z.Autoservis.Grad);
                query = query.Include(z => z.Autoservis.Grad.Drzava);
                query = query.Include(z => z.Autoservis.Uloga);
                query = query.Include(z => z.Autoservis.Usluge);
                query = query.Include(z => z.Autoservis.Vozilo);
                query = query.Include(z => z.FirmaAutodijelova);
                query = query.Include(z => z.FirmaAutodijelova.Grad);
                query = query.Include(z => z.FirmaAutodijelova.Grad.Drzava);
                query = query.Include(z => z.FirmaAutodijelova.Uloga);
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


       
       
    

