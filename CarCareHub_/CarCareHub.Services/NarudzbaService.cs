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


    public class NarudzbaService : BaseCRUDService<Model.Narudzba, Database.Narudzba, NarudzbaSearchObject, NarudzbaInsert, NarudzbaUpdate>, INarudzbaService
    {
        CarCareHub.Services.Database.CchV2AliContext _dbContext;
        IMapper _mapper { get; set; }

        public NarudzbaService(CchV2AliContext dbContext, IMapper mapper) : base(dbContext, mapper)
        {
            _dbContext = dbContext;
            _mapper = mapper;
        }
        public override Task<Model.Narudzba> Insert(Model.NarudzbaInsert insert)
        {
          //  insert.UkupnaCijenaNarudzbe=insert.NarudzbaStavkas
          //uraditi zbir svih ukuonih cijena proizvoda 
            return base.Insert(insert);
        }

        public override async Task<Model.Narudzba> Update(int id, Model.NarudzbaUpdate update)
        {
            return await base.Update(id, update);
        }

        public override async Task<Model.Narudzba> Delete(int id)
        {
            return await base.Delete(id);
        }


        public override IQueryable<Database.Narudzba> AddInclude(IQueryable<Database.Narudzba> query, NarudzbaSearchObject? search = null)
        {
            // Uključujemo samo entitet Uloge
            if (search?.IsAllIncluded == true)
            {
                //query = query.Include(z => z.NarudzbaStavke);
                //query = query.Include(z => z.NarudzbaStavke.Proizvod);
                //query = query.Include(z => z.NarudzbaStavke.Proizvod.Proizvodjac);
                //query = query.Include(z => z.NarudzbaStavke.Proizvod.Kategorija);
                //query = query.Include(z => z.Popust.Autoservis);
                //query = query.Include(z => z.Popust.Autoservis.Grad);
                //query = query.Include(z => z.Popust.Autoservis.Grad.Drzava);
                //query = query.Include(z => z.Popust.Autoservis.Uloga);
                //query = query.Include(z => z.Popust.Autoservis.Usluge);
                //query = query.Include(z => z.Popust.Autoservis.Vozilo);
                //query = query.Include(z => z.Popust.FirmaAutodijelova);
                //query = query.Include(z => z.Popust.FirmaAutodijelova.Grad);
                //query = query.Include(z => z.Popust.FirmaAutodijelova.Izvjestaj);
                //query = query.Include(z => z.Popust.FirmaAutodijelova.Uloga);
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


       
       
    

