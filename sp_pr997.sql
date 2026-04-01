drop procedure sp_pr997;		
create procedure sp_pr997(a_no_remesa CHAR(10))
returning integer,
		  char(100);

-- Pase de Remesa del reasegurador a Estado de Cuenta
-- Creado por Henry Giron
-- Fecha 15/12/2009
-- SIS v.2.0 - DEIVID, S.A.

DEFINE _anio_reas		Char(9);
DEFINE _trim_reas		Smallint;
define _cod_banco		char(3);
define _cod_origen_ban	char(3);
define _cod_origen_rea	char(3);
define _renglon			smallint;
define _tipo			char(2);

define _cuenta_banco	char(25);
define _cuenta			char(25);
define _debito			dec(16,2);
define _credito			dec(16,2);
define _cod_coasegur	char(3);
define _cod_auxiliar	char(5);
define _periodo			char(7);
define _centro_costo	char(3);
define _cod_ramo		char(3);
define _cod_subramo		char(3);
define _tipo_comp		smallint;
define _existe  		smallint;
DEFINE s_renglon,_tipo_trim        SMALLINT;
DEFINE s_cod_clase		VARCHAR(10);
DEFINE s_cod_contrato	VARCHAR(10);
DEFINE s_des_cod_clase  VARCHAR(10);
define s_credito        dec(16,2);

define _error			integer;
define _error_isam		integer;
define _error_desc		char(100);

begin
on exception set _error, _error_isam, _error_desc
	return _error, _error_desc;
end exception

select cod_banco,
	   cod_coasegur,
	   tipo,
	   periodo,
	   ccosto,
	   cod_contrato,
	   monto	
  into _cod_banco,
       _cod_coasegur,
	   _tipo,
	   _periodo,
	   _centro_costo,
	   s_cod_contrato,
	   s_credito
  from reatrx1
 where no_remesa = a_no_remesa;

if _periodo is null then
	return 1, "Falta asignar el Periodo de la Remesa";
end if

select tipo into _tipo_trim from reacontr where cod_contrato = s_cod_contrato;

CALL sp_rea002(_periodo,_tipo_trim) RETURNING _anio_reas,_trim_reas;

foreach
 select	renglon,
        cod_ramo,
		debito,
		credito
   into	_renglon,
        _cod_ramo,
		_debito,
		_credito
   from reatrx2
  where no_remesa = a_no_remesa

		if _debito is null then
		   LET _debito = 0 ;
		end if

		if _credito is null then
		   LET _credito = 0 ;
		end if

		select max(renglon)
		  into s_renglon
		  from reaestct2
	     where ano          = _anio_reas
		   and trimestre    = _trim_reas
		   and contrato     = s_cod_contrato 
		   and reasegurador = _cod_coasegur;

		if s_renglon is null then
		   LET s_renglon =	0;
		end if

		LET s_renglon =	s_renglon + 1;

		if s_cod_contrato is null then
		   LET s_cod_contrato =	"";
		end if

	    LET s_cod_clase = _cod_ramo;

		select nombre
		  into s_des_cod_clase
	      from rearamo
		 where ramo_reas = s_cod_clase; 

	    LET s_des_cod_clase = s_des_cod_clase; 

		INSERT INTO reaestct2 (ano,trimestre,reasegurador,contrato,renglon,concepto1,concepto2,debe,haber,ramo_reas)
		VALUES (_anio_reas,_trim_reas,_cod_coasegur,s_cod_contrato,s_renglon,"",s_des_cod_clase,_debito,_credito,s_cod_clase) ;

end foreach

let _existe = 0;
select count(*) 
  into _existe 
  from reaestct1 
 where ano          = _anio_reas 
   and trimestre    = _trim_reas
   and reasegurador = _cod_coasegur 
   and contrato     = s_cod_contrato;   -- Debe existir encabezado 

if _existe = 0 then 

	-- primer saldo en cero
	INSERT INTO reaestct1  
	(ano,   
	trimestre,   
	reasegurador,   
	contrato,   
	saldo_inicial,   
	saldo_final )  
	VALUES(
	_anio_reas,   
	_trim_reas,   
	_cod_coasegur,   
	s_cod_contrato,   
	0,   
	0 );

end if
-- actualiza saldo final
update reaestct1 
   set saldo_final  = saldo_final + s_credito
 where ano          = _anio_reas 
   and trimestre    = _trim_reas
   and reasegurador = _cod_coasegur
   and contrato     = s_cod_contrato;


-- actualiza estatus
update reatrx1
   set actualizado = 1
 where no_remesa   = a_no_remesa;

end

return 0, "Actualizacion Exitosa";

end procedure 	