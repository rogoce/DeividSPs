drop procedure sp_sac259;

create procedure "informix".sp_sac259(a_periodo char(7))
returning char(30) as cuenta,
          char(3) as grupo,
          char(10) as nombre,
		  dec(16,2) as monto,
		  varchar(50) as nom_cta;

define _cuenta		char(30);
define _grupo		char(3);
define _no_poliza   char(10);
define _debito		dec(16,2);
define _credito		dec(16,2);
define _cnt         int;
define _no_tranrec  char(10);
define _cod_subramo char(3);
define _reservas_ind    dec(16,2);
define _part_rea_ind    dec(16,2);
define _rea_cedido_ind  dec(16,2);
define _reservas_col    dec(16,2);
define _part_rea_col    dec(16,2);
define _rea_cedido_col  dec(16,2);
define _cta_nombre      varchar(50);

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
    and periodo = a_periodo
	
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
    and periodo = a_periodo
	
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

	select cta_nombre
	  into _cta_nombre
	  from cglcuentas
	 where cta_cuenta = _cuenta;
	
	
	return _cuenta,
	       _grupo,
		   (case when _grupo = '001' then 'INDIVIDUAL' else 'COLECTIVO' end),
		   _debito + _credito,
		   _cta_nombre
		   with resume;

end foreach

    -- Individuales
    SELECT sum(tmp_const_lib.res_ries_curso) - sum(tmp_const_lib.prima_lib),   
           sum(tmp_const_lib.rea_ries_curso) - sum( tmp_const_lib.rea_prima_lib),   
           sum(tmp_const_lib.rea_cedido) 
      INTO _reservas_ind,
           _part_rea_ind,
           _rea_cedido_ind
      FROM emipomae,   
           endedmae,   
           tmp_const_lib  
     WHERE ( endedmae.no_poliza = emipomae.no_poliza ) and  
           ( tmp_const_lib.id_recibo = endedmae.no_factura ) and  
           ( ( emipomae.cod_subramo <> '012' and 
               tmp_const_lib.periodo = a_periodo) )   ; 
           
     -- Colectivo
    SELECT sum(tmp_const_lib.res_ries_curso) - sum(tmp_const_lib.prima_lib),   
           sum(tmp_const_lib.rea_ries_curso) - sum( tmp_const_lib.rea_prima_lib),   
           sum(tmp_const_lib.rea_cedido) 
      INTO _reservas_col,
           _part_rea_col,
           _rea_cedido_col
      FROM emipomae,   
           endedmae,   
           tmp_const_lib  
     WHERE ( endedmae.no_poliza = emipomae.no_poliza ) and  
           ( tmp_const_lib.id_recibo = endedmae.no_factura ) and  
           ( ( emipomae.cod_subramo = '012' and 
               tmp_const_lib.periodo = a_periodo) )   ; 

	select cta_nombre
	  into _cta_nombre
	  from cglcuentas
	 where cta_cuenta = '55101010401';
	                
    return '55101010401',
           '001',
           'INDIVIDUAL',   
           _reservas_ind,
		   _cta_nombre with resume;        

    return '55101010401',
           '002',
           'COLECTIVO',   
           _reservas_col,
		   _cta_nombre  with resume;        

	select cta_nombre
	  into _cta_nombre
	  from cglcuentas
	 where cta_cuenta = '552010104';

    return '552010104',
           '001',
           'INDIVIDUAL',   
           _part_rea_ind,
		   _cta_nombre  with resume;        

    return '552010104',
           '002',
           'COLECTIVO',   
           _part_rea_col,
		   _cta_nombre  with resume;        

	select cta_nombre
	  into _cta_nombre
	  from cglcuentas
	 where cta_cuenta = '51101010401';

    return '51101010401',
           '001',
           'INDIVIDUAL',   
           _rea_cedido_ind,
		   _cta_nombre  with resume;        

    return '51101010401',
           '002',
           'COLECTIVO',   
           _rea_cedido_col,
		   _cta_nombre  with resume;        

drop table tmp_cta_1; 

end procedure
