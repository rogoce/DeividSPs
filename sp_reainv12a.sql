-- Procedimiento que carga los comprobantes de reaseguro para que se generen los registros contables
-- 
-- Creado    : 18/11/2021 - Autor: Amado Perez 
--
-- SIS v.2.0 - DEIVID, S.A.

drop procedure sp_reainv12a;		
create procedure sp_reainv12a()
returning integer,char(100);
		  	
define _no_registro	char(10);
define _contador		smallint;
define _tipo_registro	smallint;
define _sac_notrx       integer;

define _error			integer;
define _error_isam		integer;
define _error_desc		char(50);

set isolation to dirty read;

begin 
on exception set _error, _error_isam, _error_desc
	return _error, _error_desc;
end exception


--set debug file to "sp_sac161cam.trc";
--trace on;

--return 1, "Inicio " || current with resume;

let _contador = 0;

-- produccion y cobros

let _sac_notrx = null;

foreach with hold
{	select distinct r.no_registro,
	       r.tipo_registro,
		   s.sac_notrx
	  into _no_registro,
	       _tipo_registro,
	       _sac_notrx
	  from sac999:reacomp r, sac999:reacompasie s, camrea c
	 where r.no_poliza    = c.no_poliza
	   and s.no_registro  = r.no_registro
	   and r.tipo_registro in (1,2,3)
	   and r.periodo >= '2022-11'
	   and r.periodo <= '2022-11'
	   and c.actualizado = 1
	   and s.sac_notrx is not null
	 order by r.no_registro}
{select distinct r.sac_notrx 
  into _sac_notrx
  from sac999:reacompasiau e, sac999:reacompasie r, sac999:reacomp p, camrea c
 where e.no_registro = r.no_registro
   and r.no_registro = p.no_registro
   and c.no_poliza = p.no_poliza
   and e.cuenta = r.cuenta
   and r.periodo = '2022-11'
   and e.cod_auxiliar = 'BQ147'	 }
   
 --cambio solicitado segun correo de Cesia 11/07/2023
	{ select distinct r.sac_notrx
	   into _sac_notrx
	   from sac999:reacompasiau e, sac999:reacompasie r, sac999:reacomp p, camrea c
	  where e.no_registro = r.no_registro
		and r.no_registro = p.no_registro
		and c.no_poliza = p.no_poliza
		and e.cuenta = r.cuenta
		and r.periodo = '2024-04'  
		and p.tipo_registro in (1,2)
		and r.sac_notrx is not null}

   -- Cambio los que no están en camrea
	/*select distinct sac_notrx
	  into _sac_notrx
	  from sac999:reacompasie det
	inner join sac999:reacomp mae on mae.no_registro = det.no_registro
	where det.periodo = '2024-04'
	   and mae.no_documento[1,2] in ('02','20','23')
	   and tipo_registro in (1,2)
	   and sac_asientos = 2
	  */
	/*
	select distinct sac_notrx
	  into _sac_notrx
  from recasien
 where no_tranrec in (select distinct rea.no_tranrec
  from recrcmae rec
inner join emipomae emi on rec.no_poliza = emi.no_poliza
inner join rectrmae trx on trx.no_reclamo = rec.no_reclamo
inner join rectrrea rea on rea.no_tranrec = trx.no_tranrec
where emi.cod_ramo in ('002','020','023')
   and trx.periodo = '2024-04'
   and trx.actualizado = 1
   and rea.tipo_contrato = 1
--   and rea.cod_contrato = '00761'
    and rea.cod_contrato not in ('00765','00766')
union all

select distinct rea.no_tranrec
  from recrcmae rec
inner join emipomae emi on rec.no_poliza = emi.no_poliza
inner join rectrmae trx on trx.no_reclamo = rec.no_reclamo
inner join rectrrea rea on rea.no_tranrec = trx.no_tranrec
where emi.cod_ramo in ('002','020','023')
   and trx.periodo = '2024-04'
   and trx.actualizado = 1
   and rea.tipo_contrato = 5
--   and rea.cod_contrato = '00761'
    and rea.cod_contrato not in ('00767','00763'))*/
/*	
	select distinct det.sac_notrx
	  into _sac_notrx
  from sac999:reacomp mae
 inner join sac999:reacompasie det on det.no_registro = mae.no_registro
 where no_tranrec in (select distinct rea.no_tranrec
  from recrcmae rec
inner join emipomae emi on rec.no_poliza = emi.no_poliza
inner join rectrmae trx on trx.no_reclamo = rec.no_reclamo
inner join rectrrea rea on rea.no_tranrec = trx.no_tranrec
where emi.cod_ramo in ('002','020','023')
   and trx.periodo = '2024-04'
   and trx.actualizado = 1
   and rea.tipo_contrato = 1
--   and rea.cod_contrato = '00761'
    and rea.cod_contrato not in ('00765','00766')
union all

select distinct rea.no_tranrec
  from recrcmae rec
inner join emipomae emi on rec.no_poliza = emi.no_poliza
inner join rectrmae trx on trx.no_reclamo = rec.no_reclamo
inner join rectrrea rea on rea.no_tranrec = trx.no_tranrec
where emi.cod_ramo in ('002','020','023')
   and trx.periodo = '2024-04'
   and trx.actualizado = 1
   and rea.tipo_contrato = 5
--   and rea.cod_contrato = '00761'
    and rea.cod_contrato not in ('00767','00763'))
	*/
	
	/*select distinct sac_notrx
	  into _sac_notrx
  from sac999:reacompasie
 where sac_notrx is not null
   and no_registro in (
select mae.no_registro
  from emipomae emi
 inner join cobredet fac on fac.no_poliza = emi.no_poliza
 inner join cobreaco rea on rea.no_remesa  = fac.no_remesa and rea.renglon = fac.renglon
 inner join reacomae con on con.cod_contrato = rea.cod_contrato and con.tipo_contrato = 1
 inner join sac999:reacomp mae on mae.no_remesa = fac.no_remesa and mae.renglon = fac.renglon
 where emi.cod_ramo in ('002','020','023')
   and fac.periodo = '2024-04'
   and fac.actualizado = 1
   and rea.porc_partic_prima <> 5
union all

select mae.no_registro
  from emipomae emi
 inner join cobredet fac on fac.no_poliza = emi.no_poliza
 inner join cobreaco rea on rea.no_remesa  = fac.no_remesa and rea.renglon = fac.renglon
 inner join reacomae con on con.cod_contrato = rea.cod_contrato and con.tipo_contrato = 5
 inner join sac999:reacomp mae on mae.no_remesa = fac.no_remesa and mae.renglon = fac.renglon
 where emi.cod_ramo in ('002','020','023')
   and fac.periodo = '2024-04'
   and fac.actualizado = 1
   and rea.porc_partic_prima <> 95     )*/
   
/*   select distinct mae.sac_notrx
    into _sac_notrx
  from sac999:reacomp rea
 inner join deivid_tmp:det_reas_auto2024 det on det.no_poliza = rea.no_poliza and det.no_endoso = rea.no_endoso
 inner join sac999:reacompasie mae on mae.no_registro = rea.no_registro */
 
 /* select distinct mae.sac_notrx
  into _sac_notrx
  from sac999:reacomp rea
 inner join deivid_tmp:query_roman det on det.no_poliza = rea.no_poliza and det.no_endoso = rea.no_endoso
 inner join sac999:reacompasie mae on mae.no_registro = rea.no_registro
 where sac_notrx is not null */
 
 select distinct sac_notrx 
   into _sac_notrx
 from sac999:reacompasie where sac_notrx in (1618644,
1620549,
1620552,
1620554,
1620557,
1620560,
1620565,
1620566,
1620569,
1620572,
1620575,
1620577,
1620580,
1620582,
1620586,
1620588,
1620590,
1620593,
1620596,
1620598,
1620601,
1620603,
1620605,
1620606,
1620608,
1620611,
1620614,
1620618,
1620621,
1620624,
1620628,
1620631,
1620635,
1620638,
1620641,
1620646,
1620650,
1620653,
1620658,
1620662,
1620666,
1620670,
1620674,
1620677,
1620680,
1620683,
1620686,
1620690,
1620695,
1620700,
1620705,
1620709,
1620712,
1620717,
1620720,
1620722,
1620725,
1620727,
1620730,
1620731,
1620734,
1620738,
1620741,
1620743,
1620746,
1620747,
1620750,
1620753,
1620756,
1620758,
1620760,
1620762,
1620765,
1620768,
1620770,
1620774,
1620777,
1620779,
1620782,
1620785,
1620788,
1620791,
1620794,
1620797,
1620804,
1620807,
1620809,
1620813,
1620815,
1620818,
1620821,
1620824,
1620827,
1620830,
1620833,
1620835,
1620840,
1620842,
1620845,
1620849,
1620852,
1620857,
1620860,
1620863,
1620868,
1620872,
1620875,
1620877,
1620880,
1620883,
1620885,
1620888,
1620890,
1620891,
1620895,
1620898,
1620900,
1620904,
1620906,
1620908,
1620911,
1620913,
1620915,
1620918,
1620920,
1620925,
1620928,
1620933,
1620935,
1620937,
1620938,
1620940,
1620943,
1620944,
1620946,
1620949,
1620951,
1620952,
1620954,
1620955,
1620957,
1620958,
1620960,
1620961,
1620965,
1620967,
1620968,
1620969,
1620970,
1620971,
1620973,
1620974,
1620977,
1620978,
1620981,
1620985,
1620986,
1620988,
1620989,
1620990,
1620991,
1620992,
1620995,
1620996,
1620997,
1620998,
1620999,
1621003,
1621004,
1621006,
1621007,
1621008,
1621010,
1621013,
1621015,
1621018,
1621020,
1621022,
1621024,
1621028,
1621030,
1621032,
1621034,
1621036,
1621038,
1621041,
1621044,
1621046,
1621047,
1621049,
1621050,
1621052,
1621053,
1621054,
1621056,
1621058,
1621061,
1621065,
1621068,
1621071,
1621075,
1621077,
1621080,
1621082,
1621085,
1621089,
1621091,
1621095,
1621099,
1621103,
1621106,
1621110,
1621113,
1621117,
1621120,
1621122,
1621124,
1621126,
1621129,
1621132,
1621139,
1621143,
1621148,
1621152,
1621156,
1621160,
1621163,
1621166,
1621170,
1621174,
1621178,
1621181,
1621185,
1621188,
1621191,
1621195,
1621198,
1621202,
1621205,
1621209,
1621212,
1621216,
1621219,
1621223,
1621226,
1621230,
1621235,
1621239,
1621244,
1621247,
1621250,
1621254,
1621257,
1621260,
1621263,
1621265,
1621269,
1621273,
1621276,
1621279,
1621280,
1621283,
1621286,
1621289,
1621293,
1621296,
1621299,
1621302,
1621304,
1621307,
1621310,
1621314,
1621318,
1621321,
1621327,
1621330,
1621333,
1621336,
1621339,
1621342,
1621343,
1621346,
1621349,
1621353,
1621355,
1621358,
1621360,
1621363,
1621367,
1621370,
1621374,
1621376,
1621379,
1621382,
1621385,
1621391,
1621394,
1621395,
1621398,
1621403,
1621406,
1621408,
1621411,
1621413,
1621416,
1621418,
1621421,
1621423,
1621425,
1621428,
1621430,
1621431,
1621434,
1621437,
1621439,
1621441,
1621444,
1621445,
1621446,
1621448,
1621450,
1621453,
1621456,
1621459,
1621462,
1621467,
1621497,
1621499,
1621506,
1621513,
1621516,
1621519,
1621521,
1621525,
1621528,
1621529,
1621532,
1621534,
1621536,
1621538,
1621540,
1621541,
1621545,
1621548,
1621551,
1621553,
1621556,
1621559,
1621563,
1621568,
1621571,
1621573,
1621575,
1621577,
1621578,
1621581,
1621585,
1621587,
1621592,
1621595,
1621598,
1621601,
1621603,
1621605,
1621609,
1621612,
1621615,
1621617,
1621619,
1621621,
1621624,
1621625,
1621628,
1621629,
1621630,
1621632,
1621635,
1621638,
1621640,
1621641,
1621644,
1621646,
1621648,
1621651,
1621654,
1621655,
1621657,
1621658,
1621660,
1621662,
1621665,
1621666,
1621668,
1621669,
1621671,
1621674,
1621677,
1621678,
1621681,
1621682,
1621684,
1621686,
1621687,
1621689,
1621690,
1621692,
1621695,
1621708,
1621710,
1621713,
1621717,
1621719,
1621720,
1621722,
1621723,
1621724,
1621726,
1621727,
1621728,
1621729,
1621730,
1621731,
1621732,
1621733,
1621735,
1621736,
1621737,
1621738,
1621739,
1621741,
1621745,
1621748,
1621750,
1621752,
1621755,
1621757,
1621760,
1621763,
1621767,
1621770,
1621773,
1621775,
1621778,
1621780,
1621781,
1621784,
1621785,
1621786,
1621789,
1621791,
1621793,
1621796,
1621799,
1621802,
1621804
)

	
	if _sac_notrx is not null then
		call sp_sac77a(_sac_notrx) returning _error, _error_desc;
	end if
	
	let _sac_notrx = null;

end foreach
end 
let _error  = 0;
let _error_desc = "Proceso Completado ...";	
return _error, _error_desc;
end procedure;