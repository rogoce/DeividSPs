-- Procedure que carga los registros para el WEB de asegurados 

-- Procedure que carga los registros para el WEB de asegurados 
-- Enocjahaziel Carrasco 29-mayo-2013
 drop procedure sp_web22;
create procedure "informix".sp_web22(a_cod_usuario char(10) ,_filtro char(50),_sentencia_ramos char(50),_sentencia_estado char(50))
returning char(10),
char(10),
char(50),
char(50),
char(50),
char(10),
integer,
char(3),
integer,
integer;

define _cod_contratante char(10);
define _cod_pagador char(10); 
define _no_documento char(50); 
define _no_poliza char(50); 
define _nombre char(50) ;
define _cod_agente char(10);
define _estatus_poliza integer;
define _cod_ramo char(3);
define _activo integer;
define _leasing integer;
--filtros
-- p = poliza , r = ramos, s = estado 
--1 p 
--2 p,r
--3 p,s
--4 p,r,s
--5 r
--6 r,s
--7 s

if _sentencia_estado is null then
   let _sentencia_estado = "";
end if

if _sentencia_ramos is null then
   let _sentencia_ramos = "";
end if

if _filtro is null then
   let _filtro = "";
end if

--sin filtro
if _filtro = '' and _sentencia_ramos = '' and _sentencia_estado = ''  then 
foreach
SELECT cod_contratante,
       cod_pagador,
	   no_documento,
	   no_poliza,
	   nombre,
	   cod_agente,
	   estatus_poliza,
	   cod_ramo,
	   activo,
	   leasing
			INTO _cod_contratante,
			_cod_pagador, 
			_no_documento,
			_no_poliza,
			_nombre, 
			_cod_agente, 
			_estatus_poliza,
			_cod_ramo,
			_activo,
			_leasing
			from ((
			SELECT cod_contratante , emipomae.cod_pagador, no_documento, emipouni.no_poliza, cliclien.nombre , cod_agente, estatus_poliza, emipomae.cod_ramo,emipouni.activo,emipomae.leasing
			from emipouni
			inner join emipoagt on emipoagt.no_poliza = emipouni.no_poliza
			inner join cliclien on cod_cliente = cod_asegurado
			inner join emipomae on emipomae.no_poliza = emipouni.no_poliza
			where (emipomae.cod_pagador= a_cod_usuario) and activo <> 0  and actualizado = 1) 
			UNION
			(SELECT cod_contratante , emipomae.cod_pagador, no_documento, emipouni.no_poliza, cliclien.nombre , cod_agente, estatus_poliza, emipomae.cod_ramo,emipouni.activo,emipomae.leasing
			from emipouni
			inner join emipoagt on emipoagt.no_poliza = emipouni.no_poliza
			inner join cliclien on cod_cliente = cod_asegurado
			inner join emipomae on emipomae.no_poliza = emipouni.no_poliza
			where (cod_asegurado= a_cod_usuario ) and activo <> 0 and actualizado = 1))
  as tabla ORDER BY estatus_poliza =1 DESC ,estatus_poliza =3 DESC, estatus_poliza =2 DESC
  
  if trim(_cod_ramo) = '023' then
     select nombre
	   into _nombre
	   from cliclien
	  where cod_cliente = _cod_contratante;
  end if
  
  RETURN _cod_contratante,
         _cod_pagador, 
         _no_documento,
         _no_poliza, 
         _nombre , 
         _cod_agente,
         _estatus_poliza, 
         _cod_ramo,
         _activo,
         _leasing with resume;
  end foreach
end if
--filtro 1
if _filtro <> '' and _sentencia_ramos = '' and _sentencia_estado = ''  then 
foreach
SELECT cod_contratante,
       cod_pagador,
	   no_documento,
	   no_poliza,
	   nombre,
	   cod_agente,
	   estatus_poliza,
	   cod_ramo,
	   activo,
	   leasing
			INTO _cod_contratante,
			_cod_pagador, 
			_no_documento,
			_no_poliza,
			_nombre, 
			_cod_agente, 
			_estatus_poliza,
			_cod_ramo,
			_activo,
			_leasing
			from ((
			SELECT cod_contratante , emipomae.cod_pagador, no_documento, emipouni.no_poliza, cliclien.nombre , cod_agente, estatus_poliza, emipomae.cod_ramo,emipouni.activo,emipomae.leasing
			from emipouni
			inner join emipoagt on emipoagt.no_poliza = emipouni.no_poliza
			inner join cliclien on cod_cliente = cod_asegurado
			inner join emipomae on emipomae.no_poliza = emipouni.no_poliza
			where (emipomae.cod_pagador= a_cod_usuario) and activo <> 0  and emipomae.no_poliza = _filtro) 
			UNION
			(SELECT cod_contratante , emipomae.cod_pagador, no_documento, emipouni.no_poliza, cliclien.nombre , cod_agente, estatus_poliza, emipomae.cod_ramo,emipouni.activo,emipomae.leasing
			from emipouni
			inner join emipoagt on emipoagt.no_poliza = emipouni.no_poliza
			inner join cliclien on cod_cliente = cod_asegurado
			inner join emipomae on emipomae.no_poliza = emipouni.no_poliza
			where (cod_asegurado= a_cod_usuario ) and activo <> 0  and emipomae.no_poliza= _filtro )  )
  as tabla ORDER BY estatus_poliza =1 DESC ,estatus_poliza =3 DESC, estatus_poliza =2 DESC
  
	 if trim(_cod_ramo) = '023' then
		 select nombre
		   into _nombre
		   from cliclien
		  where cod_cliente = _cod_contratante;
	  end if
  RETURN _cod_contratante,
         _cod_pagador, 
         _no_documento,
         _no_poliza, 
         _nombre , 
         _cod_agente,
         _estatus_poliza, 
         _cod_ramo,
         _activo,
         _leasing with resume;
  end foreach
end if
--filtro 2
if _filtro <> '' and _sentencia_ramos <> '' and _sentencia_estado = ''  then 
foreach
SELECT cod_contratante,
       cod_pagador,
	   no_documento,
	   no_poliza,
	   nombre,
	   cod_agente,
	   estatus_poliza,
	   cod_ramo,
	   activo,
	   leasing
			INTO _cod_contratante,
			_cod_pagador, 
			_no_documento,
			_no_poliza,
			_nombre, 
			_cod_agente, 
			_estatus_poliza,
			_cod_ramo,
			_activo,
			_leasing
			from ((
			SELECT cod_contratante , emipomae.cod_pagador, no_documento, emipouni.no_poliza, cliclien.nombre , cod_agente, estatus_poliza, emipomae.cod_ramo,emipouni.activo,emipomae.leasing
			from emipouni
			inner join emipoagt on emipoagt.no_poliza = emipouni.no_poliza
			inner join cliclien on cod_cliente = cod_asegurado
			inner join emipomae on emipomae.no_poliza = emipouni.no_poliza
			where (emipomae.cod_pagador= a_cod_usuario) and activo <> 0  and emipomae.no_poliza = _filtro and emipomae.cod_ramo = trim(_sentencia_ramos) )
			UNION
			(SELECT cod_contratante , emipomae.cod_pagador, no_documento, emipouni.no_poliza, cliclien.nombre , cod_agente, estatus_poliza, emipomae.cod_ramo,emipouni.activo,emipomae.leasing
			from emipouni
			inner join emipoagt on emipoagt.no_poliza = emipouni.no_poliza
			inner join cliclien on cod_cliente = cod_asegurado
			inner join emipomae on emipomae.no_poliza = emipouni.no_poliza
			where (cod_asegurado= a_cod_usuario ) and activo <> 0  and emipomae.no_poliza= _filtro and emipomae.cod_ramo = trim(_sentencia_ramos) )  )
  as tabla ORDER BY estatus_poliza =1 DESC ,estatus_poliza =3 DESC, estatus_poliza =2 DESC
  
		if trim(_cod_ramo) = '023' then
		 select nombre
		   into _nombre
		   from cliclien
		  where cod_cliente = _cod_contratante;
		end if
  
  RETURN _cod_contratante,
         _cod_pagador, 
         _no_documento,
         _no_poliza, 
         _nombre , 
         _cod_agente,
         _estatus_poliza, 
         _cod_ramo,
         _activo,
         _leasing with resume;
  end foreach
end if
--filtro 3
if _filtro <> '' and _sentencia_ramos = '' and _sentencia_estado <> ''  then 
foreach
SELECT cod_contratante,
       cod_pagador,
	   no_documento,
	   no_poliza,
	   nombre,
	   cod_agente,
	   estatus_poliza,
	   cod_ramo,
	   activo,
	   leasing
			INTO _cod_contratante,
			_cod_pagador, 
			_no_documento,
			_no_poliza,
			_nombre, 
			_cod_agente, 
			_estatus_poliza,
			_cod_ramo,
			_activo,
			_leasing
			from ((
			SELECT cod_contratante , emipomae.cod_pagador, no_documento, emipouni.no_poliza, cliclien.nombre , cod_agente, estatus_poliza, emipomae.cod_ramo,emipouni.activo,emipomae.leasing
			from emipouni
			inner join emipoagt on emipoagt.no_poliza = emipouni.no_poliza
			inner join cliclien on cod_cliente = cod_asegurado
			inner join emipomae on emipomae.no_poliza = emipouni.no_poliza
			where (emipomae.cod_pagador= a_cod_usuario) and activo <> 0  and emipomae.no_poliza = _filtro and estatus_poliza = trim(_sentencia_estado) )
			UNION
			(SELECT cod_contratante , emipomae.cod_pagador, no_documento, emipouni.no_poliza, cliclien.nombre , cod_agente, estatus_poliza, emipomae.cod_ramo,emipouni.activo,emipomae.leasing
			from emipouni
			inner join emipoagt on emipoagt.no_poliza = emipouni.no_poliza
			inner join cliclien on cod_cliente = cod_asegurado
			inner join emipomae on emipomae.no_poliza = emipouni.no_poliza
			where (cod_asegurado= a_cod_usuario ) and activo <> 0  and emipomae.no_poliza= _filtro and estatus_poliza = trim(_sentencia_estado) )  )
  as tabla ORDER BY estatus_poliza =1 DESC ,estatus_poliza =3 DESC, estatus_poliza =2 DESC
  
    if trim(_cod_ramo) = '023' then
     select nombre
	   into _nombre
	   from cliclien
	  where cod_cliente = _cod_contratante;
	end if
  
  RETURN _cod_contratante,
         _cod_pagador, 
         _no_documento,
         _no_poliza, 
         _nombre , 
         _cod_agente,
         _estatus_poliza, 
         _cod_ramo,
         _activo,
         _leasing with resume;
  end foreach
end if 
--filtro 4
if _filtro <> '' and _sentencia_ramos <>'' and _sentencia_estado <> ''  then 
foreach
SELECT cod_contratante,
       cod_pagador,
	   no_documento,
	   no_poliza,
	   nombre,
	   cod_agente,
	   estatus_poliza,
	   cod_ramo,
	   activo,
	   leasing
			INTO _cod_contratante,
			_cod_pagador, 
			_no_documento,
			_no_poliza,
			_nombre, 
			_cod_agente, 
			_estatus_poliza,
			_cod_ramo,
			_activo,
			_leasing
			from ((
			SELECT cod_contratante , emipomae.cod_pagador, no_documento, emipouni.no_poliza, cliclien.nombre , cod_agente, estatus_poliza, emipomae.cod_ramo,emipouni.activo,emipomae.leasing
			from emipouni
			inner join emipoagt on emipoagt.no_poliza = emipouni.no_poliza
			inner join cliclien on cod_cliente = cod_asegurado
			inner join emipomae on emipomae.no_poliza = emipouni.no_poliza
			where (emipomae.cod_pagador= a_cod_usuario) and activo <> 0  and emipomae.no_poliza = _filtro and estatus_poliza = trim(_sentencia_estado) and emipomae.cod_ramo = trim(_sentencia_ramos) )
			UNION
			(SELECT cod_contratante , emipomae.cod_pagador, no_documento, emipouni.no_poliza, cliclien.nombre , cod_agente, estatus_poliza, emipomae.cod_ramo,emipouni.activo,emipomae.leasing
			from emipouni
			inner join emipoagt on emipoagt.no_poliza = emipouni.no_poliza
			inner join cliclien on cod_cliente = cod_asegurado
			inner join emipomae on emipomae.no_poliza = emipouni.no_poliza
			where (cod_asegurado= a_cod_usuario ) and activo <> 0  and emipomae.no_poliza= _filtro and estatus_poliza = trim(_sentencia_estado) and emipomae.cod_ramo = trim(_sentencia_ramos))  )
  as tabla ORDER BY estatus_poliza =1 DESC ,estatus_poliza =3 DESC, estatus_poliza =2 DESC
  
		if trim(_cod_ramo) = '023' then
		 select nombre
		   into _nombre
		   from cliclien
		  where cod_cliente = _cod_contratante;
		end if
  
  RETURN _cod_contratante,
         _cod_pagador, 
         _no_documento,
         _no_poliza, 
         _nombre , 
         _cod_agente,
         _estatus_poliza, 
         _cod_ramo,
         _activo,
         _leasing with resume;
  end foreach
end if 
--filtro 5 
if _sentencia_ramos <> '' and  _filtro = '' and _sentencia_estado = ''  then 
foreach
SELECT cod_contratante,
       cod_pagador,
	   no_documento,
	   no_poliza,
	   nombre,
	   cod_agente,
	   estatus_poliza,
	   cod_ramo,
	   activo,
	   leasing
			INTO _cod_contratante,
			_cod_pagador, 
			_no_documento,
			_no_poliza,
			_nombre, 
			_cod_agente, 
			_estatus_poliza,
			_cod_ramo,
			_activo,
			_leasing
			from ((
			SELECT cod_contratante , emipomae.cod_pagador, no_documento, emipouni.no_poliza, cliclien.nombre , cod_agente, estatus_poliza, emipomae.cod_ramo,emipouni.activo,emipomae.leasing
			from emipouni
			inner join emipoagt on emipoagt.no_poliza = emipouni.no_poliza
			inner join cliclien on cod_cliente = cod_asegurado
			inner join emipomae on emipomae.no_poliza = emipouni.no_poliza
			where (emipomae.cod_pagador= a_cod_usuario) and activo <> 0  and emipomae.cod_ramo = trim(_sentencia_ramos) )
			UNION
			(SELECT cod_contratante , emipomae.cod_pagador, no_documento, emipouni.no_poliza, cliclien.nombre , cod_agente, estatus_poliza, emipomae.cod_ramo,emipouni.activo,emipomae.leasing
			from emipouni
			inner join emipoagt on emipoagt.no_poliza = emipouni.no_poliza
			inner join cliclien on cod_cliente = cod_asegurado
			inner join emipomae on emipomae.no_poliza = emipouni.no_poliza
			where (cod_asegurado= a_cod_usuario ) and activo <> 0   and emipomae.cod_ramo = trim(_sentencia_ramos))  )
  as tabla ORDER BY estatus_poliza =1 DESC ,estatus_poliza =3 DESC, estatus_poliza =2 DESC
 
	 if trim(_cod_ramo) = '023' then
		 select nombre
		   into _nombre
		   from cliclien
		  where cod_cliente = _cod_contratante;
	  end if
 
  RETURN _cod_contratante,
         _cod_pagador, 
         _no_documento,
         _no_poliza, 
         _nombre , 
         _cod_agente,
         _estatus_poliza, 
         _cod_ramo,
         _activo,
         _leasing with resume;
  end foreach
end if 
if _sentencia_ramos <> '' and  _filtro = '' and _sentencia_estado <> ''  then 
foreach
SELECT cod_contratante,
       cod_pagador,
	   no_documento,
	   no_poliza,
	   nombre,
	   cod_agente,
	   estatus_poliza,
	   cod_ramo,
	   activo,
	   leasing
			INTO _cod_contratante,
			_cod_pagador, 
			_no_documento,
			_no_poliza,
			_nombre, 
			_cod_agente, 
			_estatus_poliza,
			_cod_ramo,
			_activo,
			_leasing
			from ((
			SELECT cod_contratante , emipomae.cod_pagador, no_documento, emipouni.no_poliza, cliclien.nombre , cod_agente, estatus_poliza, emipomae.cod_ramo,emipouni.activo,emipomae.leasing
			from emipouni
			inner join emipoagt on emipoagt.no_poliza = emipouni.no_poliza
			inner join cliclien on cod_cliente = cod_asegurado
			inner join emipomae on emipomae.no_poliza = emipouni.no_poliza
			where (emipomae.cod_pagador= a_cod_usuario) and activo <> 0  and emipomae.cod_ramo = trim(_sentencia_ramos)  and estatus_poliza = trim(_sentencia_estado))
			UNION
			(SELECT cod_contratante , emipomae.cod_pagador, no_documento, emipouni.no_poliza, cliclien.nombre , cod_agente, estatus_poliza, emipomae.cod_ramo,emipouni.activo,emipomae.leasing
			from emipouni
			inner join emipoagt on emipoagt.no_poliza = emipouni.no_poliza
			inner join cliclien on cod_cliente = cod_asegurado
			inner join emipomae on emipomae.no_poliza = emipouni.no_poliza
			where (cod_asegurado= a_cod_usuario ) and activo <> 0   and emipomae.cod_ramo = trim(_sentencia_ramos) and estatus_poliza = trim(_sentencia_estado) )  )
  as tabla ORDER BY estatus_poliza =1 DESC ,estatus_poliza =3 DESC, estatus_poliza =2 DESC
	
	if trim(_cod_ramo) = '023' then
		 select nombre
		   into _nombre
		   from cliclien
		  where cod_cliente = _cod_contratante;
	  end if
	  
  RETURN _cod_contratante,
         _cod_pagador, 
         _no_documento,
         _no_poliza, 
         _nombre , 
         _cod_agente,
         _estatus_poliza, 
         _cod_ramo,
         _activo,
         _leasing with resume;
  end foreach
end if 

if _sentencia_ramos = '' and  _filtro = '' and _sentencia_estado <> ''  then 
foreach
SELECT cod_contratante,
       cod_pagador,
	   no_documento,
	   no_poliza,
	   nombre,
	   cod_agente,
	   estatus_poliza,
	   cod_ramo,
	   activo,
	   leasing
			INTO _cod_contratante,
			_cod_pagador, 
			_no_documento,
			_no_poliza,
			_nombre, 
			_cod_agente, 
			_estatus_poliza,
			_cod_ramo,
			_activo,
			_leasing
			from ((
			SELECT cod_contratante , emipomae.cod_pagador, no_documento, emipouni.no_poliza, cliclien.nombre , cod_agente, estatus_poliza, emipomae.cod_ramo,emipouni.activo,emipomae.leasing
			from emipouni
			inner join emipoagt on emipoagt.no_poliza = emipouni.no_poliza
			inner join cliclien on cod_cliente = cod_asegurado
			inner join emipomae on emipomae.no_poliza = emipouni.no_poliza
			where (emipomae.cod_pagador= a_cod_usuario) and activo <> 0  and estatus_poliza = trim(_sentencia_estado))
			UNION
			(SELECT cod_contratante , emipomae.cod_pagador, no_documento, emipouni.no_poliza, cliclien.nombre , cod_agente, estatus_poliza, emipomae.cod_ramo,emipouni.activo,emipomae.leasing
			from emipouni
			inner join emipoagt on emipoagt.no_poliza = emipouni.no_poliza
			inner join cliclien on cod_cliente = cod_asegurado
			inner join emipomae on emipomae.no_poliza = emipouni.no_poliza
			where (cod_asegurado= a_cod_usuario ) and activo <> 0  and estatus_poliza = trim(_sentencia_estado) )  )
  as tabla ORDER BY estatus_poliza =1 DESC ,estatus_poliza =3 DESC, estatus_poliza =2 DESC
  
	if trim(_cod_ramo) = '023' then
	 select nombre
	   into _nombre
	   from cliclien
	  where cod_cliente = _cod_contratante;
	end if
	
  RETURN _cod_contratante,
         _cod_pagador, 
         _no_documento,
         _no_poliza, 
         _nombre , 
         _cod_agente,
         _estatus_poliza, 
         _cod_ramo,
         _activo,
         _leasing with resume;
  end foreach
end if 
  end procedure