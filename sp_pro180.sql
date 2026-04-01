-- Informe Anual para INUSE

-- Creado    : 21/03/2007 - Autor: Ruben Arnaez

-- SIS v.2.0 - DEIVID, S.A.

 DROP PROCEDURE sp_pro180;

create procedure sp_pro180(a_ano char(4))
returning CHAR(3),   -- Codigo del Ramo
		  CHAR(50),	 -- Nombre del Subramo
		  INTEGER,	 --      Cantidad de P¢liza Vigentes 
		  DEC(16,2), -- Suma total de P¢liza Vigentes
		  INTEGER,	 --      Cantidad de P¢liza Renovadas
		  DEC(16,2), -- Suma total de P¢liza Renovadas    
		  INTEGER,	 --      Cantidad de P¢liza Nuevas
		  DEC(16,2), -- Suma total de P¢liza Nuevas
		  INTEGER,	 --      Cantidad de P¢liza Canceladas
		  DEC(16,2), -- Suma total de P¢liza Canceladas 
		  INTEGER,	 --      Cantidad de P¢liza Vencidas
		  DEC(16,2), -- Suma total de P¢liza Vencidas
		  CHAR(3),	 -- Nombre del Ramo
		  CHAR(50);  -- Nombre del Subramo		  
		  
define _fecha			date;
define _cod_ramo        char(3);
define _cod_subramo     char(3);
define _nombre_ramo		char(50);
define _nombre_subramo  char(50);     
define _cant_pol_vig    integer;
define _suma_pol_vig	dec(16,2);
define _cant_pol_ren    integer;
define _suma_pol_ren    dec(16,2);
define _cant_pol_nue	integer;
define _suma_pol_nue	dec(16,2);
define _cant_pol_can	integer;
define _suma_pol_can	dec(16,2);
define _cant_pol_ven	integer;
define _suma_pol_ven	dec(16,2);							  
							  

define v_filtros        char(255);
define _compania		char(3);
define v_status         char(1);
define v_cod_ramo		char(3);
define v_cod_subramo    char(3);

SET ISOLATION TO DIRTY READ;

let _fecha = MDY(12,31,a_ano);

create temp table tmp_inuse(
cod_ramo		char(3),
cod_subramo     char(3),
cant_pol_vig	integer		default 0,
suma_pol_vig	dec(16,2)	default 0,
cant_pol_ren	integer		default 0,
suma_pol_ren	dec(16,2)	default 0,
cant_pol_nue	integer		default 0,
suma_pol_nue	dec(16,2)	default 0,
cant_pol_can	integer		default 0,
suma_pol_can	dec(16,2)	default 0,
cant_pol_ven	integer		default 0,
suma_pol_ven	dec(16,2)	default 0
) with no log;

-- Polizas Vigentes


--call sp_pro03("001", "001", _fecha, "*") RETURNING v_filtros;
CALL sp_pro95(
'001',
'001',
_fecha,
'*',
'4;Ex') RETURNING v_filtros;

 foreach
	 select	   a.cod_ramo,
	           a.cod_subramo,
			   count(*),
			   sum(a.suma_asegurada)

	   into    _cod_ramo,
	           _cod_subramo,
			   _cant_pol_vig,
			   _suma_pol_vig

	    from   temp_perfil a
	    group  by cod_ramo, cod_subramo

		insert into tmp_inuse(
			   cod_ramo,
			   cod_subramo,
			   cant_pol_vig,
			   suma_pol_vig
			   )
		values (_cod_ramo,
		       _cod_subramo,
		       _cant_pol_vig,
		       _suma_pol_vig
		       );

end foreach	    

drop table temp_perfil;

-- Polizas Renovadas 
	     
 foreach
  	 select p.cod_ramo,
  	        p.cod_subramo,
  	        count(*),
  	        sum(e.suma_asegurada)
       into	_cod_ramo,
	        _cod_subramo,
			_cant_pol_ren,
			_suma_pol_ren
	   from endedmae e, emipomae p
	  where e.no_poliza    = p.no_poliza
	    and e.actualizado  = 1
	    and e.periodo[1,4] = a_ano
		and p.nueva_renov  = "R"
		and e.cod_endomov  = "011"
      group by p.cod_ramo, p.cod_subramo


	insert into tmp_inuse(
			   cod_ramo,
			   cod_subramo,
			   cant_pol_ren,
			   suma_pol_ren
			   )
		values (_cod_ramo,
		       _cod_subramo,
			   _cant_pol_ren,
		       _suma_pol_ren
		       );

end foreach

 -- Polizas Nuevas	

 foreach
  	 select p.cod_ramo,
  	        p.cod_subramo,
  	        count(*),
  	        sum(e.suma_asegurada)
       into	_cod_ramo,
	        _cod_subramo,
			_cant_pol_nue,
			_suma_pol_nue
	   from endedmae e, emipomae p
	  where e.no_poliza    = p.no_poliza
	    and e.actualizado  = 1
	    and e.periodo[1,4] = a_ano
		and p.nueva_renov  = "N"
		and e.cod_endomov  = "011"
		group by p.cod_ramo, p.cod_subramo

	insert into tmp_inuse(
			   cod_ramo,
			   cod_subramo,
			   cant_pol_nue,
			   suma_pol_nue
			   )
		values (_cod_ramo,
		       _cod_subramo,
			   _cant_pol_nue,
		       _suma_pol_nue
		       );

end foreach

-- Polizas Canceladas

 foreach
	select  p.cod_ramo,
  	        p.cod_subramo,
  	        count(*),
  	        sum(e.suma_asegurada)
	   into	_cod_ramo,
	        _cod_subramo,
			_cant_pol_can,
			_suma_pol_can
	   from endedmae e, emipomae p
	  where e.no_poliza    = p.no_poliza
	    and e.actualizado  = 1
	    and e.periodo[1,4] = a_ano
		and e.cod_endomov  = "002"
	  group by p.cod_ramo, p.cod_subramo

	insert into tmp_inuse(
			   cod_ramo,
			   cod_subramo,
			   cant_pol_can,
			   suma_pol_can
			   )
		values (_cod_ramo,
		       _cod_subramo,
			   _cant_pol_can,
		       _suma_pol_can
		       );

end foreach

-- Polizas Vencidas

foreach
	select  p.cod_ramo,
  	        p.cod_subramo,
  	        count(*),
  	        sum(e.suma_asegurada)
	   into	_cod_ramo,
	        _cod_subramo,
			_cant_pol_ven,
			_suma_pol_ven
	   from endedmae e, emipomae p
	  where e.no_poliza    = p.no_poliza
	    and e.actualizado  = 1
	    and e.periodo[1,4] = a_ano
		and p.estatus_poliza = "3"
	 	and p.vigencia_final <= _fecha
	  group by p.cod_ramo, p.cod_subramo

	insert into tmp_inuse(
			   cod_ramo,
			   cod_subramo,
			   cant_pol_ven,
			   suma_pol_ven
			   )
		values (_cod_ramo,
		       _cod_subramo,
			   _cant_pol_ven,
		       _suma_pol_ven
		       );

end foreach

 foreach
		 select cod_ramo,
		        cod_subramo,
		        sum(cant_pol_vig),
		  		sum(suma_pol_vig),
				sum(cant_pol_ren),
		  		sum(suma_pol_ren),
				sum(cant_pol_nue),
		  		sum(suma_pol_nue),
				sum(cant_pol_can),
		  		sum(suma_pol_can),
				sum(cant_pol_ven),
		  		sum(suma_pol_ven)
		   into _cod_ramo,
				_cod_subramo,
		        _cant_pol_vig,
				_suma_pol_vig,
				_cant_pol_ren,
				_suma_pol_ren,
				_cant_pol_nue,
				_suma_pol_nue,
				_cant_pol_can,
				_suma_pol_can,
				_cant_pol_ven,
				_suma_pol_ven
		   from tmp_inuse
		   group by 1, 2 
		   order by 1, 2 

	   select nombre
		 into _nombre_ramo
		 from prdramo
		where cod_ramo = _cod_ramo;
		 	

		select nombre
		  into _nombre_subramo
		  from prdsubra
		 where cod_ramo    = _cod_ramo
		   and cod_subramo = _cod_subramo;

		
	 	return _cod_subramo,	
		   	   _nombre_subramo,
			   _cant_pol_vig,
			   _suma_pol_vig,
		       _cant_pol_ren,
			   _suma_pol_ren,
			   _cant_pol_nue,
			   _suma_pol_nue,
			   _cant_pol_can,
			   _suma_pol_can,
			   _cant_pol_ven,
			   _suma_pol_ven,
			   _cod_ramo,
			   _nombre_ramo
			   with resume;

end foreach;

drop table tmp_inuse;

end procedure;