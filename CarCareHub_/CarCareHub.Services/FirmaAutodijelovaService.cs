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


    public class FirmaAutodijelovaService : BaseCRUDService<Model.FirmaAutodijelova, Database.FirmaAutodijelova, FirmaAutodijelovaSearchObject, FirmaAutodijelovaInsert, FirmaAutodijelovaUpdate>, IFirmaAutodijelovaService
    {
        CarCareHub.Services.Database.CchV2AliContext _dbContext;
        IMapper _mapper { get; set; }

        public FirmaAutodijelovaService(CchV2AliContext dbContext, IMapper mapper) : base(dbContext, mapper)
        {
            _dbContext = dbContext;
            _mapper = mapper;
        }
        public override Task<Model.FirmaAutodijelova> Insert(Model.FirmaAutodijelovaInsert insert)
        {
            return base.Insert(insert);
        }

        public override async Task<Model.FirmaAutodijelova> Update(int id, Model.FirmaAutodijelovaUpdate update)
        {
            return await base.Update(id, update);
        }

        public override async Task<Model.FirmaAutodijelova> Delete(int id)
        {
            return await base.Delete(id);
        }

        public override IQueryable<Database.FirmaAutodijelova> AddFilter(IQueryable<Database.FirmaAutodijelova> query, FirmaAutodijelovaSearchObject? search = null)
        {


            if (search?.JIB.HasValue==true)
            {
                query = query.Where(x => (x.JIB.ToString()).StartsWith ((search.JIB.ToString())));
            }
            if (search?.MBS.HasValue == true)
            {
                query = query.Where(x => (x.MBS.ToString()).StartsWith((search.MBS.ToString())));
            }
            if (search?.NazivFirme!=null)
            {
                query = query.Where(x => (x.NazivFirme).StartsWith(search.NazivFirme));
            }
            if (search?.Adresa != null)
            {
                query = query.Where(x => (x.Adresa).StartsWith(search.Adresa));
            }
            if (search?.MarkaVozila != null)
            {
                query = query.Where(m => m.Proizvods.Any(u => u.Vozilo.MarkaVozila.StartsWith(search.MarkaVozila)));

            }
            if (search?.ModelVozila != null)
            {
                query = query.Where(m => m.Proizvods.Any(u => u.Vozilo.ModelVozila.StartsWith(search.ModelVozila)));

            }
            if (search?.GodisteVozila.HasValue == true)
            {
                query = query.Where(m => m.Proizvods.Any(u => u.Vozilo.GodisteVozila.ToString().StartsWith(search.GodisteVozila.ToString())));

            }

            return base.AddFilter(query, search);
        }

        public override IQueryable<Database.FirmaAutodijelova> AddInclude(IQueryable<Database.FirmaAutodijelova> query, FirmaAutodijelovaSearchObject? search = null)
        {
            // Uključujemo samo entitet Uloge
            if (search?.IsAllncluded == true)
            {
                query = query.Include(z => z.Grad);
                query = query.Include(z => z.Grad.Drzava);
                query = query.Include(z => z.Uloga);
                query = query.Include(z => z.Proizvods);
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


       
       
    

