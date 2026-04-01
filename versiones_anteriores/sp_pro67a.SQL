-- Consulta de Clientes Global

-- Creado    : 14/06/2001 - Autor: Armando Moreno M.
-- Modificado: 14/06/2001 - Autor: Armando Moreno M.

-- SIS v.2.0 - d_prod_sp_prd67_dw1 - DEIVID, S.A.

drop procedure sp_pro67a;
create procedure sp_pro67a(a_cod_cliente char(10))
returning char(20),	 -- poliza
		  char(5),	 -- unidad
		  date,      -- vig ini
		  date,      -- vig fin
		  dec(16,2), -- prima neta
		  dec(16,2), -- impuesto
		  dec(16,2), -- prima bruta
		  dec(16,2), -- saldo
		  smallint,	 -- estatus poliza
		  char(50),	 -- nombre corredor
		  char(50),	 -- nombre ramo
		  char(100),
		  char(15), -- nombre cte
		  dec(16,2),
		  char(10),
		  char(50);

define v_cod_cliente  		char(10);
define _cod_ase		  		char(10);
define v_nombre_corredor	char(50); 
define v_documento   		char(20);
define v_vig_ini			date;
define v_vig_fin			date;
define v_prima_neta			dec(16,2);
define v_prima_bruta		dec(16,2);
define v_impuesto			dec(16,2);					 
define v_saldo				dec(16,2);					 
define v_estatus_pol	    smallint;					 
define v_actualizado	    smallint;					 
define v_no_poliza	 	    char(10);					 
define v_no_unidad	 	    char(5);					 
define v_cod_agente	 	    char(5);					 
define v_nombre_ramo		char(50);					 
define v_cod_ramo			char(3);					 
define v_nombre_cte			char(100);					 
define _cantidad			integer;					 
define _monto           	dec(16,2);
define _li_cnt              integer;
define _leasing             smallint;
define _cod_cont            char(10);		
define _error			    integer;
define _desc                varchar(15);
define v_ejecutivo,_nombre_formapag    	char(50);
define _cod_formapag	char(3);
define v_cod_cobrador,_cod_vendedor 	char(3); 

set isolation to dirty read;

drop table IF EXISTS tmp_busq;
														 
create temp table tmp_busq(
	no_documento	char(20),
	no_unidad		char(5),
	vig_ini         date,
	vig_fin         date,
	prima_neta      dec(16,2),
	impuesto        dec(16,2),
	prima_bruta     dec(16,2),
	saldo		    dec(16,2),
	estatus_pol     smallint,
	nombre_corredor char(50),
	nombre_ramo     char(50),
	nombre_cte      char(100),
	monto           dec(16,2),
	no_poliza       char(10),
	nombre_ejecutivo char(50),
	primary key		(no_poliza)
	) with no log;


--SACAR INFORMACION DE LA POLIZA

{if a_cod_cliente = '19986' then
	set debug file to "sp_pro67.trc";
	trace on;
end if}
LET v_ejecutivo = '';
begin
ON EXCEPTION SET _error 
		return v_documento,
			   v_no_unidad,		 
			   v_vig_ini,
			   v_vig_fin,     
			   v_prima_neta, 
			   v_impuesto,
			   v_prima_bruta,
			   v_saldo,
			   v_estatus_pol,
			   v_nombre_corredor,
			   v_nombre_ramo,
			   v_nombre_cte,
			   trim(_desc),
			   _monto,
			   v_no_poliza,
			   v_ejecutivo;
END EXCEPTION

 select	nombre
   into v_nombre_cte
   from	cliclien
  where cod_cliente = a_cod_cliente;

let v_documento = null;
let v_nombre_ramo= null;
let v_nombre_corredor = null;
let _monto = 0;

if v_documento is null then

foreach --1
	select distinct(no_documento)
	  into v_documento
	  from emipomae
	 where cod_contratante = a_cod_cliente
	   and actualizado     = 1
	   
	let _desc = '1';

	if v_documento is null then
		exit foreach;
	end if

	let v_no_poliza = sp_sis21(v_documento);

	 select	no_documento,
	 		vigencia_inic,
			vigencia_final,
			saldo,
			estatus_poliza,
			actualizado,
			cod_ramo,
			prima_neta,
			prima_bruta,
			impuesto,
			leasing,
			cod_contratante,
			cod_formapag
	   into v_documento,
	   		v_vig_ini,
			v_vig_fin,
			v_saldo,
			v_estatus_pol,
			v_actualizado,
			v_cod_ramo,
			v_prima_neta,
			v_prima_bruta,
			v_impuesto,
			_leasing,
			_cod_cont,
			_cod_formapag
	   from	emipomae
	  where no_poliza = v_no_poliza;

	foreach
		select cod_agente
		  into v_cod_agente
		  from emipoagt
		 where no_poliza = v_no_poliza
		exit foreach;
	end foreach

	if _leasing = 1 then
		foreach
			select no_unidad
			  into v_no_unidad
			  from emipouni
			 where no_poliza = v_no_poliza

			exit foreach;
		end foreach
	else
		let v_no_unidad = "";
	end if

	select nombre,cod_vendedor
	  into v_nombre_corredor,_cod_vendedor
	  from agtagent
	 where cod_agente = v_cod_agente;


       select nombre
	     into v_ejecutivo
		 from agtvende
		where cod_vendedor = _cod_vendedor;

	select nombre
	  into v_nombre_ramo
	  from prdramo
	 where cod_ramo = v_cod_ramo;

	 let v_saldo = sp_cob115b("001", "001", v_documento, "");

	select count(*)
	  into _li_cnt
	  from tmp_busq
	 where no_poliza = v_no_poliza;

	if _li_cnt > 0 then
		continue foreach;
	end if

	insert into tmp_busq(
			no_documento,	
			no_unidad,		
			vig_ini,        
			vig_fin,        
			prima_neta,     
			impuesto,       
			prima_bruta,    
			saldo,		   
			estatus_pol,    
			nombre_corredor,
			nombre_ramo,    
			nombre_cte,     
			monto,          
			no_poliza,
			nombre_ejecutivo)
	values (
			v_documento,
			v_no_unidad, 
			v_vig_ini,
			v_vig_fin,     
			v_prima_neta, 
			v_impuesto,
			v_prima_bruta,
			v_saldo,
			v_estatus_pol,
			v_nombre_corredor,
			v_nombre_ramo,
			v_nombre_cte,
			_monto,
			v_no_poliza,
			v_ejecutivo);

end foreach

foreach
	 select	e.prima_neta,
			e.prima_bruta,
			e.impuesto,
			e.no_unidad,
			e.no_poliza,
			t.vigencia_inic,
			t.vigencia_final,
			t.saldo,
			t.estatus_poliza,
			t.actualizado,
			t.cod_ramo,
			t.no_documento,
			e.cod_formapag
	   into v_prima_neta,
			v_prima_bruta,
			v_impuesto,
			v_no_unidad,
			v_no_poliza,
			v_vig_ini,
			v_vig_fin,
			v_saldo,
			v_estatus_pol,
			v_actualizado,
			v_cod_ramo,
			v_documento,
			_cod_formapag
	   from	emipouni e, emipomae t
	  where e.no_poliza     = t.no_poliza
	    and e.cod_asegurado = a_cod_cliente
		and t.actualizado   = 1
		
	let _desc = '2 ';

	let _li_cnt = 0;	
		
	select count(*)
	  into _li_cnt
	  from tmp_busq
	 where no_poliza = v_no_poliza;

	if _li_cnt > 0 then
	
		let _desc = "update";
		
		update tmp_busq
		   set no_unidad = v_no_unidad
		 where no_poliza = v_no_poliza;
		 

		continue foreach;
	end if

	
{	select a.vigencia_inic,
		   a.vigencia_final,
		   a.saldo,
		   a.estatus_poliza,
		   a.actualizado,
		   a.cod_ramo,
		   a.no_documento,
		   a.cod_formapag 
	  into v_vig_ini,
		   v_vig_fin,
		   v_saldo,
		   v_estatus_pol,
		   v_actualizado,
		   v_cod_ramo,
		   v_documento,
		   _cod_formapag
	  from emipomae a
	 where a.no_poliza = v_no_poliza;
}
    let _desc = "saldo";
	 
{	foreach
		 select	cod_agente
		   into	v_cod_agente
		   from	emipoagt
		  where no_poliza = v_no_poliza
		  exit foreach;
	end foreach

    let _desc = "nombre agt";	
	
	select nombre, cod_vendedor
	  into v_nombre_corredor, _cod_vendedor
	  from agtagent
	 where cod_agente = v_cod_agente;

   let _desc = "nombre ramo";	
	 
	select nombre
	  into v_nombre_ramo
	  from prdramo
	 where cod_ramo = v_cod_ramo;
}
	let v_saldo = sp_cob115b("001", "001", v_documento, ""); 
	
       select nombre
	     into v_ejecutivo
		 from agtvende
		where cod_vendedor = _cod_vendedor;		

	insert into tmp_busq(
			no_documento,	
			no_unidad,		
			vig_ini,        
			vig_fin,        
			prima_neta,     
			impuesto,       
			prima_bruta,    
			saldo,		   
			estatus_pol,    
			nombre_corredor,
			nombre_ramo,    
			nombre_cte,     
			monto,          
			no_poliza,
			nombre_ejecutivo)
	values (
			v_documento,
			v_no_unidad,		 
			v_vig_ini,
			v_vig_fin,     
			v_prima_neta, 
			v_impuesto,
			v_prima_bruta,
			v_saldo,
			v_estatus_pol,
			v_nombre_corredor,
			v_nombre_ramo,
			v_nombre_cte,
			_monto,
			v_no_poliza,
			v_ejecutivo);
end foreach

foreach
	select no_documento
	  into v_documento
	  from tmp_busq
	  group by no_documento
	  
	let _desc = '3';	  

	let v_no_poliza = sp_sis21(v_documento);

   foreach
	select no_documento,	
		   no_unidad,		
		   vig_ini,        
		   vig_fin,        
		   prima_neta,     
		   impuesto,       
		   prima_bruta,    
		   saldo,
		   estatus_pol,
		   nombre_corredor,
		   nombre_ramo,    
		   nombre_cte,     
		   monto,          
		   no_poliza,
		   nombre_ejecutivo
	  into v_documento,
		   v_no_unidad,		 
		   v_vig_ini,
		   v_vig_fin,     
		   v_prima_neta, 
		   v_impuesto,
		   v_prima_bruta,
		   v_saldo,
		   v_estatus_pol,
		   v_nombre_corredor,
		   v_nombre_ramo,
		   v_nombre_cte,
		   _monto,
		   v_no_poliza,
		   v_ejecutivo
      from tmp_busq
	 where no_poliza = v_no_poliza
	 
	    select cod_ramo,cod_formapag 
		  into v_cod_ramo,_cod_formapag
		  from emipomae
		 where no_poliza = v_no_poliza;
	 
  		foreach
  			 select	cod_agente
  			   into	v_cod_agente
  			   from	emipoagt
  			  where no_poliza = v_no_poliza
  			  exit foreach;
  		end foreach

  		select	nombre, cod_vendedor
  		  into v_nombre_corredor, _cod_vendedor
  		  from	agtagent
  		 where cod_agente = v_cod_agente;
	 
  		select	nombre
  		  into	v_nombre_ramo
  		  from	prdramo
  		 where cod_ramo = v_cod_ramo;
		 
       select nombre
	     into v_ejecutivo
		 from agtvende
		where cod_vendedor = _cod_vendedor;		 
	 
	return  v_documento,
			v_no_unidad,		 
			v_vig_ini,
			v_vig_fin,     
			v_prima_neta, 
			v_impuesto,
			v_prima_bruta,
			v_saldo,
			v_estatus_pol,
			v_nombre_corredor,
			v_nombre_ramo,
			v_nombre_cte,
			"",
			_monto,
			v_no_poliza,
			v_ejecutivo
			with resume;
   end foreach
end foreach
end if

--si no encuentra es que es dependiente buscar la poliza
if v_documento is null then

 select	count(*)
   into	_cantidad
   from	emidepen
  where cod_cliente = a_cod_cliente;

if _cantidad > 0 then
	let _desc = '4';
		
	foreach
		 select	no_unidad,
				no_poliza
		   into	v_no_unidad,
				v_no_poliza
		   from	emidepen
		  where cod_cliente = a_cod_cliente		
		exit foreach;
	end foreach

	 select	cod_asegurado
	   into _cod_ase
	   from	emipouni
	  where no_poliza = v_no_poliza
	    and no_unidad = v_no_unidad;

	foreach
		 select	prima_neta,
				prima_bruta,
				impuesto,
				no_unidad,
				no_poliza
		   into v_prima_neta,
				v_prima_bruta,
				v_impuesto,
				v_no_unidad,
				v_no_poliza
		   from	emipouni
		  where cod_asegurado = _cod_ase
		    and no_poliza     = v_no_poliza

  		 if v_no_poliza is null	then	 --SI NO ENCUENTRA REGISTROS EN emipouni *AMADO 18/06/2002*
  		 	select no_poliza
  		 	  into v_no_poliza
  			  from emipomae
  		 	 where cod_contratante = a_cod_cliente;
  		 end if	     

  		 select	no_documento,
		 		vigencia_inic,
				vigencia_final,
				saldo,
				estatus_poliza,
				actualizado,
				cod_ramo,
				cod_formapag
  		   into	v_documento,
		   		v_vig_ini,
				v_vig_fin,
				v_saldo,
				v_estatus_pol,
				v_actualizado,
				v_cod_ramo,
				_cod_formapag
  		   from	emipomae
  		  where no_poliza = v_no_poliza;

  		  if v_actualizado is null theN
  			let v_actualizado = 0;
  		  end if

  		  if v_actualizado <> 1 then
  			continue foreach;
  		  end if

  		foreach
  			 select	cod_agente
  			   into	v_cod_agente
  			   from	emipoagt
  			  where no_poliza = v_no_poliza
  			  exit foreach;
  		end foreach

  		select	nombre,cod_vendedor
  		  into v_nombre_corredor, _cod_vendedor
  		  from	agtagent
  		 where cod_agente = v_cod_agente;

  		select	nombre
  		  into	v_nombre_ramo
  		  from	prdramo
  		 where cod_ramo = v_cod_ramo;

		 Let v_saldo = sp_cob115b("001", "001", v_documento, "");
		 
-- Zona de Cobros
select nombre,
       cod_cobrador
  into _nombre_formapag,
       v_cod_cobrador
  from cobforpa
 where cod_formapag = _cod_formapag;
 let v_cod_cobrador = null;

if v_cod_cobrador is null then
	select cod_cobrador
	  into v_cod_cobrador
	  from agtagent
	 where cod_agente = v_cod_agente;

	select nombre 
	  into v_ejecutivo
	  from cobcobra
	 where cod_cobrador = v_cod_cobrador;
else
	let v_ejecutivo     = _nombre_formapag; 
	let v_cod_cobrador = _cod_formapag;
end if	

       select nombre
	     into v_ejecutivo
		 from agtvende
		where cod_vendedor = _cod_vendedor;		 

		return v_documento,
			   v_no_unidad,		 
			   v_vig_ini,
			   v_vig_fin,     
			   v_prima_neta, 
			   v_impuesto,
			   v_prima_bruta,
			   v_saldo,
			   v_estatus_pol,
			   v_nombre_corredor,
			   v_nombre_ramo,
			   v_nombre_cte,
			   "DEPENDIENTE",
			   _monto,
			   v_no_poliza,
			   v_ejecutivo
			   WITH RESUME;
	end foreach
end if
end if

drop table tmp_busq;
end
end procedure;