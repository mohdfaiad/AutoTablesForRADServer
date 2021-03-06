{******************************************************************************}
{                                                                              }
{  Delphi SwagDoc Library                                                      }
{  Copyright (c) 2018 Marcelo Jaloto                                           }
{  https://github.com/marcelojaloto/SwagDoc                                    }
{                                                                              }
{******************************************************************************}
{                                                                              }
{  Licensed under the Apache License, Version 2.0 (the "License");             }
{  you may not use this file except in compliance with the License.            }
{  You may obtain a copy of the License at                                     }
{                                                                              }
{      http://www.apache.org/licenses/LICENSE-2.0                              }
{                                                                              }
{  Unless required by applicable law or agreed to in writing, software         }
{  distributed under the License is distributed on an "AS IS" BASIS,           }
{  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.    }
{  See the License for the specific language governing permissions and         }
{  limitations under the License.                                              }
{                                                                              }
{******************************************************************************}

unit Swag.Doc.Path.Operation.RequestParameter;

interface

uses
  System.JSON,
  Swag.Common.Types,
  Swag.Doc.Definition;

type
  TSwagRequestParameter = class(TObject)
  private
    fName: string;
    fInLocation: TSwagRequestParameterInLocation;
    fRequired: Boolean;
    fSchema: TSwagDefinition;
    fDescription: string;
    fTypeParameter: string;
    fPattern: string;
  protected
    function ReturnInLocationToString: string;
  public
    constructor Create; reintroduce;
    destructor Destroy; override;

    function GenerateJsonObject: TJSONObject;
    procedure Load(pJson: TJSONObject);

    property InLocation: TSwagRequestParameterInLocation read fInLocation write fInLocation;
    property Name: string read fName write fName;
    property Description: string read fDescription write fDescription;
    property Required: Boolean read fRequired write fRequired;
    property Pattern: string read fPattern write fPattern;
    property Schema: TSwagDefinition read fSchema;
    property TypeParameter: string read fTypeParameter write fTypeParameter;
  end;

implementation

uses
  System.SysUtils,
  System.StrUtils,
  Swag.Common.Consts,
  Swag.Common.Types.Helpers;

const
  c_SwagRequestParameterIn = 'in';
  c_SwagRequestParameterName = 'name';
  c_SwagRequestParameterDescription = 'description';
  c_SwagRequestParameterRequired = 'required';
  c_SwagRequestParameterSchema = 'schema';
  c_SwagRequestParameterType = 'type';

{ TSwagRequestParameter }

constructor TSwagRequestParameter.Create;
begin
  inherited Create;
  fSchema := TSwagDefinition.Create;
end;

destructor TSwagRequestParameter.Destroy;
begin
  FreeAndNil(fSchema);
  inherited Destroy;
end;

function TSwagRequestParameter.GenerateJsonObject: TJSONObject;
var
  vJsonObject: TJsonObject;
begin
  vJsonObject := TJsonObject.Create;
  vJsonObject.AddPair(c_SwagRequestParameterIn, ReturnInLocationToString);
  vJsonObject.AddPair(c_SwagRequestParameterName, fName);
  if not fDescription.IsEmpty then
    vJsonObject.AddPair(c_SwagRequestParameterDescription, fDescription);
  if not fPattern.IsEmpty then
    vJsonObject.AddPair('pattern', fPattern);

  vJsonObject.AddPair(c_SwagRequestParameterRequired, TJSONBool.Create(fRequired));

  if (not fSchema.Name.IsEmpty) then
    vJsonObject.AddPair(c_SwagRequestParameterSchema, fSchema.GenerateJsonRefDefinition)
  else if Assigned(fSchema.JsonSchema) then
    vJsonObject.AddPair(c_SwagRequestParameterSchema, fSchema.JsonSchema)
  else if not fTypeParameter.IsEmpty then
    vJsonObject.AddPair(c_SwagRequestParameterType, fTypeParameter);

  Result := vJsonObject;
end;

procedure TSwagRequestParameter.Load(pJson: TJSONObject);
begin
  if Assigned(pJson.Values[c_SwagRequestParameterRequired]) then
    fRequired := (pJson.Values[c_SwagRequestParameterRequired] as TJSONBool).AsBoolean
  else
    fRequired := False;

  if Assigned(pJson.Values['pattern']) then
    fPattern := pJson.Values['pattern'].Value;

  if Assigned(pJson.Values[c_SwagRequestParameterName]) then
    fName := pJson.Values[c_SwagRequestParameterName].Value;

  if Assigned(pJson.Values['in']) then
    fInLocation.ToType(pJson.Values['in'].Value);

  fTypeParameter := pJson.Values[c_SwagRequestParameterType].Value;
end;

function TSwagRequestParameter.ReturnInLocationToString: string;
begin
  Result := c_SwagRequestParameterInLocation[fInLocation];
end;

end.
