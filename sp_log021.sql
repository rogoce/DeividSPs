-- Proceso que inserta endedmae a endpool0 solo cuando es interna = 0 
-- Creado    : 05/04/2017 - Autor: Henry Girón 

drop procedure sp_log021;
create procedure sp_log021(a_no_poliza char(10),a_no_endoso char(5),a_usuario char(8))
returning integer, CHAR(100);

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
define _mensaje             char(100);
define _cod_tipoprod        CHAR(3);  
DEFINE _tipo_prod           smallint;
define _cnt                 smallint;

-- Actualiza el Periodo del Endoso de acuerdo a la vigencia
-- Requerimientos NIFF
let _leasing = 0;
let _estado_pro = 0;
let _estado_log = 0;
let _cantidad = 0;

select count(*)
  into _cantidad
  from insuser
 where usuario = a_usuario
   and cia_depto in ('008','010') and status = 'A';
   
if _cantidad <> 1 then
	LET _mensaje = 'Endoso de usuario no valido.';
	return 1,_mensaje;
end if   

select interna,
       cod_endomov,
	   cod_tipocan,
	   no_documento,
	   cod_sucursal
  into _interna,
       _cod_endomov,
	   _cod_tipocan,
	   _no_documento,
	   _sucursal
  from endedmae
 where no_poliza = a_no_poliza
   and no_endoso = a_no_endoso;
   
if _cod_endomov in('020','016','017','027','018','026','028','024','025') then  -- Endoso que no aplican
	LET _mensaje = 'Endoso que no Aplica (020).';
	return 1,_mensaje;
end if   

if _interna <> 0 then   -- Internos no aplican
	LET _mensaje = 'Endoso Internos no Aplican.';
	return 1,_mensaje;
end if

select count(*)
  into _cnt
  from emifafac
 where no_poliza = a_no_poliza
   and no_endoso = a_no_endoso;
   
if _cnt is null then
	let _cnt = 0;
end if
if _cnt = 0 then	--polizas con facultativo no deben entrar al pool, puesto en produccion 13/04/2018
else
	LET _mensaje = 'Poliza con Facultativo no Aplican.';
	return 1,_mensaje;
end if

LET _no_poliza = sp_sis21(_no_documento);

 SELECT cod_contratante, 
		cod_tipoprod, 
		leasing 
  INTO _cod_contratante, 
       _cod_tipoprod, 
	   _leasing  
  FROM emipomae 
 WHERE no_poliza = _no_poliza;  
 
 	let _cod_acreedor = '';  
	let _cod_agente = '';  
	let _cod_vendedor = '';  
	let _cantidad = 0; 
	
	SELECT tipo_produccion 
	  INTO _tipo_prod 
	  FROM emitipro 
	 WHERE cod_tipoprod = _cod_tipoprod; 

	-- Excluir Coas. Minoritario --	SOLICITUD: JFONSECA,CASO:26102 06/09/2017 
	if _tipo_prod = 3 then  
	  LET _mensaje = 'Endoso Coaseguro Minoritario no Aplican.';
	  return 1,_mensaje;
	end if	
	
	select count(*)
	  into _cantidad
	  from insagen
	 where sucursal_promotoria <> '001'
	   and codigo_agencia not in ( '010','001')
	   and codigo_agencia  = _sucursal ;	
	   
	   if _cantidad <> 0 then
			LET _mensaje = 'Endoso de sucursales.';
			return 1,_mensaje;	   
	   end if
	
  	if _sucursal = '010' then -- se exceptua sucursal - Transitmica 
		let _sucursal = '001'; 
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
   
if _cantidad is null then
	let _cantidad = 0 ;
end if   

if _cantidad <> 0 then
	LET _mensaje = 'Endoso ya registrado.';
	return 1,_mensaje;
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
'',
'',
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
   and no_endoso = a_no_endoso;
   --and actualizado = 1;	  

   	LET _mensaje = 'Actualizacion Exitosa.';
	return 0,_mensaje;
   
end procedure