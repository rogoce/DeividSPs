-- Proceso que inserta endedmae a endpool0 solo cuando es interna = 0*
-- Creado    : 05/04/2017 - Autor: Henry Girón

drop procedure sp_log022;
create procedure sp_log022(a_usuario char(8))
returning integer;

define _no_documento		char(20);
define _cod_contratante 	char(10);	 
define _cantidad			smallint;
define _interna		    	smallint;
define _cod_endomov     	char(3);
define _cod_tipocan     	char(3);
define _no_poliza       	char(10);
define _sucursal        	char(3);
define _cod_agente			char(5);
define _cod_acreedor		char(5);
define _cod_vendedor		char(3);
define _leasing				smallint;
define _estado_pro			smallint;
define _estado_log			smallint;
define _desc_suc		    char(100);
define _cod_tipocalc		char(3);
define _no_factura   		char(10);
define a_no_poliza char(10);
define a_no_endoso char(5);

-- Actualiza el Periodo del Endoso de acuerdo a la vigencia
-- Requerimientos NIFF
let _leasing = 0;
let _estado_pro = 1;
let _estado_log= 2;

FOREACH
select n.interna,
       n.cod_endomov,
	   n.cod_tipocan,
	   n.no_documento,
	   n.no_poliza,
	   n.no_endoso,
	   n.cod_tipocalc,
	   n.no_factura
into _interna,
       _cod_endomov,
	   _cod_tipocan,
	   _no_documento,
       a_no_poliza,	
       a_no_endoso,
	   _cod_tipocalc,
       _no_factura	   
  from emipomae e  ,insagen s  , endedmae n  , endtimov j
 where n.no_factura is not null
   and n.no_poliza = e.no_poliza
   and s.codigo_agencia = e.sucursal_origen
   and year(n.date_added) = 2017
      and month(n.date_added) = 4
and day(n.date_added) in (24,25,26,27,28,29)  
   and s.codigo_compania = '001'
--   and (s.sucursal_promotoria in ("004","006","001") or s.sucursal_promotoria <> e.sucursal_origen)
   and trim(n.no_documento) = trim(e.no_documento)
   and trim(n.cod_endomov) = trim(j.cod_endomov)
--  and n.cod_tipocan = '001'
   and n.cod_endomov <> '002'
--   and n.cod_tipocalc not in ('004','001')
   and n.actualizado = 1
    and n.interna = 0
   order by n.periodo,n.no_documento   
   
if _cod_endomov in ('020','016','017','027','018','026','028') then  -- Endoso que no aplican
	continue foreach;
end if     
 
if _cod_endomov in ('002') then  -- Endoso que no aplican
	--return 1;
	if _cod_tipocalc in ('004','001') then
	       continue foreach;
	end if   
end if   

if _interna <> 0 then   -- Internos no aplican
	--return 1;
	continue foreach;
end if

LET _no_poliza = sp_sis21(_no_documento);

 SELECT cod_contratante,
        sucursal_origen,	    
		leasing
  INTO _cod_contratante,
	   _sucursal,	   
	   _leasing
  FROM emipomae
 WHERE no_poliza = _no_poliza;
 
 	let _cod_acreedor = '';
	let _cod_agente = ''; 
	let _cod_vendedor = ''; 	
	
  	if _sucursal = '010' then
		let _sucursal = '001';
	end if		

	let _cantidad = 0;
	
	select count(*)
	  into _cantidad
	  from insagen
	 where sucursal_promotoria <> '001'
	   and codigo_agencia not in ( '010','001')
	   and codigo_agencia  = _sucursal ;	
	   
	   if _cantidad <> 0 then
			continue foreach;   
	   end if	
	
	foreach
		select distinct e.cod_acreedor
		  into _cod_acreedor
		  from  emipoacr e, emiacre n
		 where e.cod_acreedor = n.cod_acreedor
		   and e.no_poliza = _no_poliza		
	end foreach	
	 
	foreach
		select cod_agente
		  into _cod_agente
		  from emipoagt
		 where no_poliza = _no_poliza
		exit foreach;
	end foreach	 	

	select cod_vendedor
 	  into _cod_vendedor
	  from agtagent
	 where cod_agente = _cod_agente;	 		     

-- Buscar si esta en el pool de endoso

select count(*)
  into _cantidad
  from endpool0
 where no_poliza = a_no_poliza
   and no_endoso = a_no_endoso;

if _cantidad <> 0 then
	--return 1;
	continue foreach;
end if

insert into endpool0(
         no_poliza,
         no_endoso,
         no_documento,
         user_added,
         fecha_added,
         cod_sucursal,
         no_factura,
         imprimir,
         user_facturo,
         cod_endomov,
         cod_tipocan,
         user_imprimio,
         fecha_imprimio,
         user_elimino,
         fecha_elimino,
         cod_cliente,
         cod_agente,
         cod_acreedor,
         cod_vendedor,
         leasing,
         estado_pro,
         estado_log
		 )
select
no_poliza,
no_endoso,
no_documento,
a_usuario,
fecha_emision,
cod_sucursal,
no_factura,
0,
user_added,
cod_endomov,
cod_tipocan,
user_added,
fecha_emision,
'',
'',
_cod_contratante,
_cod_agente,
_cod_acreedor,
_cod_vendedor,
_leasing,
_estado_pro,
_estado_log
  from endedmae
 where no_poliza = a_no_poliza
   and no_endoso = a_no_endoso
   and actualizado = 1;	  

end foreach

   return 0;
   
end procedure