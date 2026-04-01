drop procedure ap_apadea2;

create procedure "informix".ap_apadea2()
returning char(30),
          char(3),
          char(10),
		  dec(16,2);

define _cuenta		char(30);
define _grupo		char(3);
define _no_poliza   char(10);
define _debito		dec(16,2);
define _credito		dec(16,2);
define _cnt         int;
define _no_tranrec  char(10);

create temp table tmp_cta_1 (
   grupo	 char(3),
   cuenta    char(30),
   poliza    char(10),  
   debito    dec(16,2), 
   credito   dec(16,2)) with no log;
   
  

--SET DEBUG FILE TO "sp_sis83.trc";
--TRACE ON;


set isolation to dirty read;

let _cnt = 0;

foreach
 select id_recibo,
        res_ries_curso, 
        rea_ries_curso, 
        prima_lib,
		rea_prima_lib,
		rea_cedido
   into _id_recibo,
        _res_ries_curso,
        _rea_ries_curso,
		_prima_lib,
		_rea_prima_lib,
		_rea_cedido
   from tmp_const_lib
  where periodo = "2023-01"
	
 let _cnt = 0;
 
 select no_poliza
   into _no_poliza
   from endedmae
  where no_factura = _id_recibo;
  
 select cod_subramo
   into _cod_subramo
   from emipomae
  where no_poliza = _no_poliza;
  	
 if _cod_subramo <> '012' then
	insert into tmp_cta_1 values (
	  '001',
	  _cuenta,
	  _no_poliza,
	  _debito,
	  _credito);
 else
	insert into tmp_cta_1 values (
	  '002',
	  _cuenta,
	  _no_poliza,
	  _debito,
	  _credito);
 end if
end foreach	

foreach
 select cuenta,
        no_tranrec, 
        debito, 
        credito
   into _cuenta,
        _no_tranrec,
        _debito,
		_credito
   from recasien
  where cuenta in ("55301010401")
    and periodo = "2023-01"
	
 let _cnt = 0;
 
 select no_poliza
   into _no_poliza
   from rectrmae a, recrcmae b
  where a.no_reclamo = b.no_reclamo
    and a.no_tranrec = _no_tranrec;  
 
 select count(*)
   into _cnt
   from emipouni
  where no_poliza = _no_poliza;
  	
 if _cnt = 1 then
	insert into tmp_cta_1 values (
	  '001',
	  _cuenta,
	  _no_poliza,
	  _debito,
	  _credito);
 else
	insert into tmp_cta_1 values (
	  '002',
	  _cuenta,
	  _no_poliza,
	  _debito,
	  _credito);
 end if
end foreach	

foreach
	select cuenta,
	       grupo,
	       sum(debito),
		   sum(credito)
 	  into _cuenta,
           _grupo,
           _debito,
           _credito
      from tmp_cta_1
    group by 1,2
    order by 1,2
	
	return _cuenta,
	       _grupo,
		   (case when _grupo = '001' then 'INDIVIDUAL' else 'COLECTIVO' end),
		   _debito + _credito
		   with resume;

end foreach

drop table tmp_cta_1; 

end procedure