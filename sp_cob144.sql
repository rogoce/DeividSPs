-- Procedimiento que Genera los Recibos Automaticos para una o varias polizas. 	

-- Creado    : 27/06/2003 - Autor: Marquelda Valdelamar 
-- Modificado: 14/07/2003 - Autor: Marquelda Valdelamar

DROP PROCEDURE sp_cob144;

CREATE PROCEDURE "informix".sp_cob144(
a_compania CHAR(3),
a_agencia  CHAR(3),
a_remesa   CHAR(10),
a_fecha    DATE
)RETURNING DEC(16,2),  -- monto de la remesa
           CHAR(50),   -- recibi de
		   CHAR(30),   -- movimiento
		   CHAR(255),  -- monto en letras
		   CHAR(20),   -- documento
		   CHAR(50),   -- nombre agente
		   DEC(16,2),  -- saldo pendiente
		   DATE,       -- fecha cubierta
		   DEC(16,2),  -- monto_efectivo
		   DEC(16,2),  -- monto cheque
		   DEC(16,2),  -- monto del pago
		   CHAR(50),   -- nombre del asegurado
		   CHAR(50),   -- tarjeta de credito
		   DEC(16,2),  -- monto tarjeta
		   DEC(16,2),  -- cambio
		   CHAR(10),   -- no_recibo
		   INT,        -- no_cheque
		   CHAR(50),     -- nombre_banco
		   CHAR(8),
		   DEC(16,2),  -- cambio
		   DEC(16,2);

DEFINE _tipo_mov          CHAR(1); 
DEFINE _tipo_agente		  CHAR(1);
DEFINE _cod_agente        CHAR(5);
DEFINE _no_poliza         CHAR(10);
DEFINE _no_reclamo        CHAR(10);
DEFINE _no_requis		  CHAR(10);
DEFINE _cod_cliente	      CHAR(10);
DEFINE _documento         CHAR(30);
DEFINE _movimiento        CHAR(30);
DEFINE _nombre_agente     CHAR(50);
DEFINE _recibi_de         CHAR(50); 
DEFINE _nombre_cliente 	  CHAR(50);
DEFINE _monto_letras      CHAR(255);
DEFINE _tarjeta           CHAR(50);
DEFINE _no_cheque         INTEGER;
DEFINE _no_recibo         CHAR(10);
DEFINE _user_added        CHAR(8);

DEFINE _fecha_cubierta    DATE; 
DEFINE _vigencia_final    DATE;

DEFINE _prima_bruta       DEC(16,2);
DEFINE _saldo             DEC(16,2);
DEFINE _monto_pago        DEC(16,2);
DEFINE _monto_renglon     DEC(16,2);
DEFINE _monto_descontado  DEC(16,2);
DEFINE _monto_cheque      DEC(16,2);
DEFINE _monto_chequeo     DEC(16,2);
DEFINE _monto_efectivo    DEC(16,2);
DEFINE _monto_visa        DEC(16,2);
DEFINE _monto_clave       DEC(16,2);
DEFINE _monto_tarjeta     DEC(16,2);
DEFINE _calculo           DEC(16,2);
DEFINE _cambio            DEC(16,2);
DEFINE _importe           DEC(16,2);
DEFINE _desc_remesa       CHAR(100);
DEFINE _coaseguro         CHAR(50);
DEFINE _ramo              CHAR(50);
DEFINE _cod_banco, _cod_ramo  CHAR(3);
DEFINE _nombre_banco      CHAR(50);

DEFINE _renglon           SMALLINT;
DEFINE _tipo_tarjeta      SMALLINT;
DEFINE _tipo_pago		  SMALLINT;
DEFINE _ramo_sis		  SMALLINT;

SET ISOLATION TO DIRTY READ;
--set debug file to "sp_cob144.trc";

Let _movimiento     = "";
Let _tarjeta        = "";
Let _monto_cheque   = 0.00;
Let _monto_visa     = 0.00;
Let _monto_clave    = 0.00;
Let _monto_tarjeta  = 0.00;
Let _monto_efectivo = 0.00;
Let _cambio = 0.00;
let _nombre_banco = null;
LET _no_cheque = "";
-- Remesa
 Select monto_chequeo,
        recibi_de,
        user_added 
   Into	_monto_chequeo,
        _recibi_de,
		_user_added
   From cobremae
  Where	no_remesa = a_remesa;

-- Monto de la remesa en letras
	Let _monto_letras = sp_sis11(_monto_chequeo);

-- Forma de pago de los recibos
 Foreach
   Select tipo_pago,
          renglon,
		  tipo_tarjeta,
		  cod_banco
	 Into _tipo_pago,
	      _renglon,
		  _tipo_tarjeta,
		  _cod_banco
	 From cobrepag
	Where no_remesa = a_remesa

   --Efectivo
   Select sum (importe)
     Into _monto_efectivo
	 From cobrepag
	Where no_remesa = a_remesa
	  and tipo_pago = 1;

   --Clave
   Select Sum(importe)
	 Into _monto_clave
	 From cobrepag
	Where no_remesa = a_remesa
	  and tipo_pago = 3;
	
	If _monto_clave is null then
		Let _monto_clave = 0.00;
	End if
    
	If _monto_clave <> 0.00 Then
	   let _tarjeta = 'Clave';	
	End If

   --Tarjeta de Credito
   Select Sum(importe)
	 Into _monto_visa
	 From cobrepag
	Where no_remesa = a_remesa
	  and tipo_pago = 4;
 	 
 	If _monto_visa is null then
		Let _monto_visa = 0.00;
	End if

   Let _monto_tarjeta= _monto_visa + _monto_clave;

   If _tarjeta = "" Then
	  If _tipo_tarjeta = 1 then
    	 Let _tarjeta = "Visa";
	  Elif _tipo_tarjeta = 2 then
		 Let _tarjeta = "MasterCard";
	  Elif _tipo_tarjeta = 3 then
	 	 Let _tarjeta = "Dinners Club";
	  Elif _tipo_tarjeta = 4 then
		 Let _tarjeta = "American Express";
	  End if
   Else
	  If _tipo_tarjeta = 1 then
    	 Let _tarjeta = trim(_tarjeta) ||  " / Visa";
	  Elif _tipo_tarjeta = 2 then
		 Let _tarjeta = trim(_tarjeta) ||  " / MasterCard";
	  Elif _tipo_tarjeta = 3 then
	 	 Let _tarjeta = trim(_tarjeta) ||  " / Dinners Club";
	  Elif _tipo_tarjeta = 4 Then
		 Let _tarjeta = trim(_tarjeta) ||  " / American Express";
	  End if
   End IF

  --Cheque
   Select sum(importe)
     Into _monto_cheque
     From cobrepag
    Where no_remesa = a_remesa
      and tipo_pago = 2;
   

   If _tipo_pago = 2 Then
    Select no_cheque
	  Into _no_cheque
	  From cobrepag
	 Where no_remesa = a_remesa
	   and renglon = _renglon;

	Select nombre 
	  Into _nombre_banco
	  From chqbanco
	 Where cod_banco = _cod_banco;
   End If

End Foreach

-- Recibos 
Foreach
 Select	tipo_mov,
        monto,
        no_poliza,
		saldo,
		no_reclamo,
		renglon,
		doc_remesa,
		no_recibo,
		desc_remesa,
		monto_descontado
   Into	_tipo_mov,
        _monto_pago,
		_no_poliza,
		_saldo,
		_no_reclamo,
		_renglon,
		_documento,
		_no_recibo,
		_desc_remesa,
		_monto_descontado
   From cobredet
  Where	no_remesa = a_remesa
    and	renglon <> 0
	and tipo_mov <> 'B'  --recibo anulado

 Let _no_poliza = sp_sis21(_documento);	
 Let _saldo = sp_cob115b(a_compania, a_agencia, _documento, a_remesa); 
 Let _saldo = _saldo - _monto_pago;
 Let _monto_renglon = _monto_pago;

-- Poliza
 Select vigencia_final,
        prima_bruta,
		cod_contratante,
		cod_ramo
   Into _vigencia_final,
		_prima_bruta,
		_cod_cliente,
		_cod_ramo
   From emipomae
  Where no_poliza = _no_poliza;

 Select ramo_sis
   Into _ramo_sis
   From prdramo
  Where cod_ramo = _cod_ramo;

-- Cliente
 Select nombre
   Into _nombre_cliente
   From cliclien
  Where cod_cliente = _cod_cliente;

-- Agente
LET _tipo_agente = '';
LET _cod_agente = '';
LET _nombre_agente = '';

FOREACH
 Select cod_agente
   Into _cod_agente
   From cobreagt
  Where no_remesa = a_remesa
    And renglon   = _renglon
  EXIT FOREACH;
END FOREACH

 Select nombre,
        tipo_agente
   Into _nombre_agente,
	    _tipo_agente
   From agtagent
  Where cod_agente = _cod_agente; 

 If trim(_tipo_agente) <> 'A' Then     
	Let _nombre_agente = 'OFICINA';
 End If
  
-- Tipos de Movimientos
   If _tipo_mov =  'P' then
      Let _movimiento = 'Pago de Poliza';
   elif _tipo_mov       = 'D' then
      Let _movimiento = 'Pago de Deducible';
	  Let _nombre_agente = trim(_desc_remesa);
   elif _tipo_mov       = 'S' then
      Let _movimiento = 'Pago de Salvamento';
	  Let _nombre_agente = trim(_desc_remesa);
   elif _tipo_mov       = 'R' then
      Let _movimiento = 'Pago de Recupero';	 
	  Let _nombre_agente = trim(_desc_remesa);
   elif _tipo_mov       = 'N' then
      Let _movimiento = 'Nota de Credito';	 
   elif _tipo_mov       = 'M' then
      Let _movimiento = 'Afectacion al Catalogo';	 
	  If _monto_descontado <> 0 Then
		Let _monto_renglon = 0;
	  End If
   elif _tipo_mov       = 'C' then
      Let _movimiento = 'Comision Descontada';	 
   elif _tipo_mov       = 'E' then
      Let _movimiento = 'Prima';
	  Select coaseguro,
		     ramo
		Into _coaseguro,
		     _ramo       
	    From cobsuspe
	   Where doc_suspenso = _documento;
	  If _coaseguro IS NULL Then
		Let  _coaseguro = '';
	  End If
	  If _ramo IS NULL Then
		Let  _ramo = '';
	  End If
--	  Let _nombre_agente = trim(_coaseguro)||'/'||trim(_ramo);
	  Let _nombre_agente = trim(_ramo);
   elif _tipo_mov       = 'A' then
      Let _movimiento = 'Aplicar Prima';	 
   elif _tipo_mov       = 'T' then
      Let _movimiento = 'Aplicar Reclamo';	 
   elif _tipo_mov       = 'B' then
      Let _movimiento = 'Recibo Anulado';	 
   else
      continue foreach;
   End if	   
	     
-- Validacion para el cambio 
  Select sum(importe)
    Into _importe
    From cobrepag
   Where no_remesa = a_remesa;  
   
   If _importe > _monto_chequeo Then
   	Let _cambio = _importe - _monto_chequeo;
   End If
   
--trace  _documento;
--trace on;

let _saldo = _saldo;
let _prima_bruta = _prima_bruta;
let _vigencia_final = _vigencia_final;

  	 
--Calculo de la Fecha Cubierta
  IF _prima_bruta is not null and _prima_bruta <> 0 THEN
  	If _ramo_sis = 5 Then
  		Let _calculo = (_saldo * 30) / _prima_bruta;
	Else
  		Let _calculo = (_saldo * 365) / _prima_bruta;
	End If
    Let _fecha_cubierta = _vigencia_final - _calculo;
  ELSE
	Let _fecha_cubierta = NULL;
  END IF

--trace off;

Return _monto_chequeo,
       _recibi_de,
 	   _movimiento,
 	   _monto_letras,
 	   _documento,
 	   _nombre_agente,
 	   _saldo,
 	   _fecha_cubierta,
 	   _monto_efectivo,
 	   _monto_cheque,
 	   _monto_pago,
 	   _nombre_cliente,
 	   _tarjeta,
 	   _monto_tarjeta,
	   _cambio,
	   _no_recibo,
	   _no_cheque,
	   _nombre_banco,
	   _user_added,
	   _monto_renglon,
	   _monto_descontado
 	   WITH RESUME;

End Foreach

END PROCEDURE
