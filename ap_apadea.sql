drop procedure ap_apadea;

create procedure "informix".ap_apadea()
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
define _cod_subramo char(3);

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
 select cuenta,
        no_poliza, 
        debito, 
        credito
   into _cuenta,
        _no_poliza,
        _debito,
		_credito
   from endasien
  where cuenta in ("53101010401","52101010401")
    and periodo = "2023-05"
	
 let _cnt = 0;
 
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
    and periodo = "2023-05"
	
 let _cnt = 0;
 
 select no_poliza
   into _no_poliza
   from rectrmae a, recrcmae b
  where a.no_reclamo = b.no_reclamo
    and a.no_tranrec = _no_tranrec;  
 
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
